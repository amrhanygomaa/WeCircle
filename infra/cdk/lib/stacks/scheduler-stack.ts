import * as cdk from 'aws-cdk-lib';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as scheduler from 'aws-cdk-lib/aws-scheduler';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';

interface SchedulerStackProps extends cdk.StackProps {
  /** ALB DNS name from ComputeStack — Lambda calls this host. */
  albDnsName: string;
}

/**
 * WeCircle EventBridge Scheduler — replaces the in-process cron (R10).
 *
 * The in-process setInterval in server.ts runs once per ECS task.
 * With 2+ tasks that means duplicate DB writes every hour.
 * This stack uses EventBridge Scheduler to fire a Lambda exactly once/hour;
 * the Lambda calls a secured internal endpoint on the backend.
 *
 * Setup (one-time, before deploy):
 *   aws ssm put-parameter \
 *     --name /wecircle/CRON_SECRET \
 *     --value "$(openssl rand -hex 32)" \
 *     --type SecureString
 *
 * After deploy:
 *   - Remove startOverdueChecker() call from server.ts (already done in this PR).
 *   - The backend /api/internal/cron/check-overdue route enforces X-Cron-Secret.
 */
export class SchedulerStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SchedulerStackProps) {
    super(scope, id, props);

    // ── CRON_SECRET SSM parameter ─────────────────────────────────────────
    // Must be created manually before first deploy (see setup above).
    // Version 1 is required by fromSecureStringParameterAttributes.
    const cronSecretParam = ssm.StringParameter.fromSecureStringParameterAttributes(
      this,
      'CronSecretParam',
      { parameterName: '/wecircle/CRON_SECRET', version: 1 },
    );

    // ── Lambda: calls the internal cron endpoint ──────────────────────────
    // No VPC needed — the ALB is internet-facing.
    // AWS SDK v3 is bundled in the Node.js 22.x Lambda runtime.
    const cronFn = new lambda.Function(this, 'CronFn', {
      functionName: 'wecircle-check-overdue-invoices',
      runtime: lambda.Runtime.NODEJS_22_X,
      handler: 'index.handler',
      timeout: cdk.Duration.seconds(30),
      environment: {
        ALB_DNS:      props.albDnsName,
        // Switch to 'https' once the ALB certificate is provisioned.
        ALB_PROTOCOL: 'http',
        ALB_PORT:     '80',
      },
      code: lambda.Code.fromInline(`
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');
const http  = require('http');
const https = require('https');

const ssmClient = new SSMClient({ region: process.env.AWS_REGION });

exports.handler = async () => {
  const { Parameter } = await ssmClient.send(new GetParameterCommand({
    Name: '/wecircle/CRON_SECRET',
    WithDecryption: true,
  }));
  const secret = Parameter.Value;
  const protocol = process.env.ALB_PROTOCOL === 'https' ? https : http;
  const port = parseInt(process.env.ALB_PORT || '80', 10);

  await new Promise((resolve, reject) => {
    const req = protocol.request(
      {
        hostname: process.env.ALB_DNS,
        port,
        path: '/api/internal/cron/check-overdue',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': 0,
          'X-Cron-Secret': secret,
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => { body += chunk; });
        res.on('end', () => {
          console.log('[CRON] status:', res.statusCode, body);
          if (res.statusCode >= 400) reject(new Error('Cron endpoint returned ' + res.statusCode));
          else resolve(res.statusCode);
        });
      },
    );
    req.on('error', reject);
    req.end();
  });
};
`),
    });

    // Grant Lambda read access to the CRON_SECRET parameter.
    cronSecretParam.grantRead(cronFn);

    // ── EventBridge Scheduler role ────────────────────────────────────────
    const schedulerRole = new iam.Role(this, 'SchedulerRole', {
      roleName: 'wecircle-eventbridge-scheduler-role',
      assumedBy: new iam.ServicePrincipal('scheduler.amazonaws.com'),
    });
    cronFn.grantInvoke(schedulerRole);

    // ── Schedule: every hour at :00 UTC ──────────────────────────────────
    new scheduler.CfnSchedule(this, 'HourlySchedule', {
      name: 'wecircle-check-overdue-invoices',
      description: 'Triggers overdue invoice check + account locking on the backend',
      scheduleExpression: 'cron(0 * * * ? *)',
      scheduleExpressionTimezone: 'UTC',
      // Allow up to 5-minute jitter so all tasks don't hit the DB simultaneously.
      flexibleTimeWindow: {
        mode: 'FLEXIBLE',
        maximumWindowInMinutes: 5,
      },
      target: {
        arn: cronFn.functionArn,
        roleArn: schedulerRole.roleArn,
        input: JSON.stringify({}),
        retryPolicy: {
          maximumRetryAttempts: 2,
          maximumEventAgeInSeconds: 300,
        },
      },
      state: 'ENABLED',
    });

    new cdk.CfnOutput(this, 'CronFunctionArn', {
      value: cronFn.functionArn,
    });
  }
}
