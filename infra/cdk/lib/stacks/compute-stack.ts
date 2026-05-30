import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as sm from 'aws-cdk-lib/aws-secretsmanager';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';

interface ComputeStackProps extends cdk.StackProps {
  vpc: ec2.Vpc;
  albSg: ec2.SecurityGroup;
  backendSg: ec2.SecurityGroup;
  /** RDS credentials secret from DatabaseStack — grants task role read access. */
  dbSecret: sm.ISecret;
}

/**
 * WeCircle ECS + ALB + OIDC CI role.
 *
 * What is created:
 *   - ECR repository for the backend Docker image
 *   - ECS Fargate cluster + service (1–3 tasks, CPU auto-scaling)
 *   - Application Load Balancer in public subnets
 *     • HTTP (port 80) → HTTPS redirect when certificateArn context is set
 *     • HTTPS (port 443) → forward to target group  (requires ACM cert)
 *     • Target group has lb_cookie stickiness for Socket.IO sessions
 *   - IAM roles: task execution (ECR/CW), task (S3/SSM/Secrets)
 *   - GitHub OIDC deploy role (replaces long-lived AWS_ACCESS_KEY_ID/SECRET)
 *
 * Prerequisites before first deploy:
 *   1. ACM certificate for api.wecircle.helpers-tech.com validated in us-east-1.
 *      Add its ARN to cdk.json context: { "certificateArn": "arn:aws:acm:..." }
 *      OR omit it — HTTP-only is used (acceptable during initial setup).
 *   2. The following SSM parameters / Secrets Manager secrets must exist
 *      (or be created manually after deploy):
 *        Secrets Manager: wecircle/DATABASE_URL, wecircle/JWT_SECRET, wecircle/GOOGLE_AI_API_KEY
 *        SSM:             /wecircle/COGNITO_USER_POOL_ID, /wecircle/COGNITO_CLIENT_ID,
 *                         /wecircle/AWS_S3_BUCKET_NAME, /wecircle/FRONTEND_URL,
 *                         /wecircle/SUPER_ADMIN_EMAIL, /wecircle/ALLOWED_ORIGINS
 *   3. After deploy, push the backend Docker image to the ECR repo printed in
 *      the BackendEcrUri output — the service shows PENDING until an image exists.
 */
export class ComputeStack extends cdk.Stack {
  readonly cluster: ecs.Cluster;
  readonly backendEcr: ecr.Repository;

  constructor(scope: Construct, id: string, props: ComputeStackProps) {
    super(scope, id, props);

    // ── ECR repository ────────────────────────────────────────────────────
    // The CI pipeline pushes images here; the ECS task pulls from here.
    this.backendEcr = new ecr.Repository(this, 'BackendEcr', {
      repositoryName: 'wecircle-backend',
      // Keep the last 10 images so rollbacks are possible within a sprint.
      lifecycleRules: [
        {
          maxImageCount: 10,
          description: 'Keep last 10 images',
        },
      ],
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // ── ECS Cluster ───────────────────────────────────────────────────────
    this.cluster = new ecs.Cluster(this, 'Cluster', {
      clusterName: 'wecircle-cluster',
      vpc: props.vpc,
      containerInsights: true,
    });

    // ── CloudWatch log group ──────────────────────────────────────────────
    const logGroup = new logs.LogGroup(this, 'BackendLogs', {
      logGroupName: '/ecs/wecircle-backend',
      retention: logs.RetentionDays.ONE_MONTH,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // ── IAM: Task Execution Role ──────────────────────────────────────────
    // ECS uses this to pull images from ECR and write logs to CloudWatch.
    // CDK attaches the managed AmazonECSTaskExecutionRolePolicy automatically;
    // we supplement it with Secrets Manager + SSM read access for the secrets
    // referenced in the container definition.
    const executionRole = new iam.Role(this, 'TaskExecutionRole', {
      roleName: 'wecircle-ecs-execution-role',
      assumedBy: new iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSTaskExecutionRolePolicy'),
      ],
    });

    // ── IAM: Task Role ────────────────────────────────────────────────────
    // What the running container is allowed to do in AWS.
    const taskRole = new iam.Role(this, 'TaskRole', {
      roleName: 'wecircle-ecs-task-role',
      assumedBy: new iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
    });

    // S3: read + write the existing assets bucket (presigned URLs, direct uploads)
    taskRole.addToPolicy(new iam.PolicyStatement({
      actions: [
        's3:GetObject',
        's3:PutObject',
        's3:DeleteObject',
        's3:GetObjectAcl',
        's3:PutObjectAcl',
      ],
      resources: [
        `arn:aws:s3:::${cdk.Fn.importValue('S3BucketName') || 'wecircle-storage-*'}`,
        `arn:aws:s3:::${cdk.Fn.importValue('S3BucketName') || 'wecircle-storage-*'}/*`,
      ],
    }));

    // S3: list bucket (required for some SDK operations)
    taskRole.addToPolicy(new iam.PolicyStatement({
      actions: ['s3:ListBucket'],
      resources: ['arn:aws:s3:::wecircle-storage-*'],
    }));

    // Secrets Manager: read all wecircle/* secrets at runtime
    taskRole.addToPolicy(new iam.PolicyStatement({
      actions: ['secretsmanager:GetSecretValue', 'secretsmanager:DescribeSecret'],
      resources: [
        `arn:aws:secretsmanager:${this.region}:${this.account}:secret:wecircle/*`,
        props.dbSecret.secretArn,
      ],
    }));

    // SSM: read all /wecircle/* parameters at runtime
    taskRole.addToPolicy(new iam.PolicyStatement({
      actions: ['ssm:GetParameter', 'ssm:GetParameters', 'ssm:GetParametersByPath'],
      resources: [
        `arn:aws:ssm:${this.region}:${this.account}:parameter/wecircle/*`,
      ],
    }));

    // CloudWatch: put custom metrics (optional — for future monitoring)
    taskRole.addToPolicy(new iam.PolicyStatement({
      actions: ['cloudwatch:PutMetricData'],
      resources: ['*'],
    }));

    // ── External secrets (defined in SSM/Secrets Manager by the operator) ──
    // These are referenced by name — CDK builds the ARN. The actual secret
    // values are populated during Phase 5 migration (for DATABASE_URL) or
    // exist already (Cognito IDs, S3 bucket name, etc.).
    const secretDbUrl = sm.Secret.fromSecretNameV2(this, 'SecretDbUrl', 'wecircle/DATABASE_URL');
    const secretJwt   = sm.Secret.fromSecretNameV2(this, 'SecretJwt', 'wecircle/JWT_SECRET');
    const secretGemini = sm.Secret.fromSecretNameV2(this, 'SecretGemini', 'wecircle/GOOGLE_AI_API_KEY');

    const paramCognitoPool   = ssm.StringParameter.fromStringParameterName(this, 'ParamCognitoPool', '/wecircle/COGNITO_USER_POOL_ID');
    const paramCognitoClient = ssm.StringParameter.fromStringParameterName(this, 'ParamCognitoClient', '/wecircle/COGNITO_CLIENT_ID');
    const paramS3Bucket      = ssm.StringParameter.fromStringParameterName(this, 'ParamS3Bucket', '/wecircle/AWS_S3_BUCKET_NAME');
    const paramFrontendUrl   = ssm.StringParameter.fromStringParameterName(this, 'ParamFrontendUrl', '/wecircle/FRONTEND_URL');
    const paramAdminEmail    = ssm.StringParameter.fromStringParameterName(this, 'ParamAdminEmail', '/wecircle/SUPER_ADMIN_EMAIL');
    const paramAllowedOrigins = ssm.StringParameter.fromStringParameterName(this, 'ParamAllowedOrigins', '/wecircle/ALLOWED_ORIGINS');

    // Grant execution role read access to secrets used in task def secrets block
    secretDbUrl.grantRead(executionRole);
    secretJwt.grantRead(executionRole);
    secretGemini.grantRead(executionRole);
    props.dbSecret.grantRead(executionRole);

    // ── Task Definition ───────────────────────────────────────────────────
    const taskDef = new ecs.FargateTaskDefinition(this, 'TaskDef', {
      family: 'wecircle-backend',
      cpu: 512,      // 0.5 vCPU
      memoryLimitMiB: 1024,
      executionRole,
      taskRole,
    });

    taskDef.addContainer('backend', {
      containerName: 'wecircle-backend',
      image: ecs.ContainerImage.fromEcrRepository(this.backendEcr, 'latest'),
      portMappings: [{ containerPort: 5001, protocol: ecs.Protocol.TCP }],
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: 'ecs',
        logGroup,
      }),
      environment: {
        NODE_ENV: 'production',
        PORT:     '5001',
        AWS_REGION: this.region,
      },
      secrets: {
        DATABASE_URL:          ecs.Secret.fromSecretsManager(secretDbUrl),
        JWT_SECRET:            ecs.Secret.fromSecretsManager(secretJwt),
        GOOGLE_AI_API_KEY:     ecs.Secret.fromSecretsManager(secretGemini),
        COGNITO_USER_POOL_ID:  ecs.Secret.fromSsmParameter(paramCognitoPool),
        COGNITO_CLIENT_ID:     ecs.Secret.fromSsmParameter(paramCognitoClient),
        AWS_S3_BUCKET_NAME:    ecs.Secret.fromSsmParameter(paramS3Bucket),
        FRONTEND_URL:          ecs.Secret.fromSsmParameter(paramFrontendUrl),
        SUPER_ADMIN_EMAIL:     ecs.Secret.fromSsmParameter(paramAdminEmail),
        ALLOWED_ORIGINS:       ecs.Secret.fromSsmParameter(paramAllowedOrigins),
      },
      healthCheck: {
        command: ['CMD-SHELL', 'wget -qO- http://localhost:5001/ || exit 1'],
        interval: cdk.Duration.seconds(30),
        timeout: cdk.Duration.seconds(5),
        retries: 3,
        startPeriod: cdk.Duration.seconds(30),
      },
    });

    // ── Application Load Balancer ─────────────────────────────────────────
    const alb = new elbv2.ApplicationLoadBalancer(this, 'Alb', {
      loadBalancerName: 'wecircle-backend-alb',
      vpc: props.vpc,
      internetFacing: true,
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC },
      securityGroup: props.albSg,
    });

    // Target group: lb_cookie stickiness keeps a Socket.IO client pinned to
    // the same backend task so its in-memory socket state remains valid.
    // (Replace with Redis adapter in increment 3 — then stickiness can be removed.)
    const targetGroup = new elbv2.ApplicationTargetGroup(this, 'TargetGroup', {
      targetGroupName: 'wecircle-backend-tg',
      vpc: props.vpc,
      protocol: elbv2.ApplicationProtocol.HTTP,
      port: 5001,
      targetType: elbv2.TargetType.IP,
      healthCheck: {
        path: '/',
        healthyHttpCodes: '200',
        interval: cdk.Duration.seconds(30),
        timeout: cdk.Duration.seconds(5),
        healthyThresholdCount: 2,
        unhealthyThresholdCount: 3,
      },
      deregistrationDelay: cdk.Duration.seconds(30),
      stickinessCookieDuration: cdk.Duration.days(1),
    });

    // Certificate ARN from cdk.json context (optional — HTTP-only until set).
    // To add HTTPS, run: cdk deploy -c certificateArn=arn:aws:acm:us-east-1:...
    const certArn = this.node.tryGetContext('certificateArn') as string | undefined;

    if (certArn) {
      alb.addListener('HttpsListener', {
        port: 443,
        protocol: elbv2.ApplicationProtocol.HTTPS,
        certificates: [elbv2.ListenerCertificate.fromArn(certArn)],
        defaultTargetGroups: [targetGroup],
        sslPolicy: elbv2.SslPolicy.TLS13_RES,
      });
      alb.addListener('HttpListener', {
        port: 80,
        defaultAction: elbv2.ListenerAction.redirect({
          protocol: 'HTTPS',
          port: '443',
          permanent: true,
        }),
      });
    } else {
      // HTTP-only — suitable for initial validation before cert is issued.
      alb.addListener('HttpListener', {
        port: 80,
        defaultTargetGroups: [targetGroup],
      });
    }

    // ── Fargate Service ───────────────────────────────────────────────────
    const service = new ecs.FargateService(this, 'BackendService', {
      serviceName: 'wecircle-backend',
      cluster: this.cluster,
      taskDefinition: taskDef,
      desiredCount: 1,
      vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS },
      securityGroups: [props.backendSg],
      assignPublicIp: false,
      // Rolling deploy: keep at least 100% healthy, surge to 200% during deploy.
      minHealthyPercent: 100,
      maxHealthyPercent: 200,
      // Auto-rollback if new tasks fail health checks.
      circuitBreaker: { rollback: true },
    });

    service.attachToApplicationTargetGroup(targetGroup);

    // ── Auto-scaling ──────────────────────────────────────────────────────
    const scaling = service.autoScaleTaskCount({ minCapacity: 1, maxCapacity: 3 });
    scaling.scaleOnCpuUtilization('CpuScaling', {
      targetUtilizationPercent: 70,
      scaleInCooldown: cdk.Duration.seconds(120),
      scaleOutCooldown: cdk.Duration.seconds(60),
    });

    // ── GitHub Actions OIDC deploy role ───────────────────────────────────
    // Replaces the long-lived AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY GitHub
    // secrets with a short-lived OIDC token (R16).
    //
    // Pre-requisite: the GitHub OIDC provider must exist in this AWS account.
    // Create it once if it doesn't:
    //   aws iam create-open-id-connect-provider \
    //     --url https://token.actions.githubusercontent.com \
    //     --client-id-list sts.amazonaws.com \
    //     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
    const githubOidc = iam.OpenIdConnectProvider.fromOpenIdConnectProviderArn(
      this,
      'GithubOidc',
      `arn:aws:iam::${this.account}:oidc-provider/token.actions.githubusercontent.com`,
    );

    const deployRole = new iam.Role(this, 'GithubActionsDeployRole', {
      roleName: 'wecircle-github-actions-deploy',
      assumedBy: new iam.WebIdentityPrincipal(
        githubOidc.openIdConnectProviderArn,
        {
          StringEquals: {
            'token.actions.githubusercontent.com:aud': 'sts.amazonaws.com',
            // Scoped to pushes on main branch of this exact repo.
            'token.actions.githubusercontent.com:sub':
              'repo:amrhanygomaa/WeCircle:ref:refs/heads/main',
          },
        },
      ),
      description: 'Assumed by GitHub Actions via OIDC — ECR push + ECS rolling deploy',
    });

    // ECR: GetAuthorizationToken must be on * (not resource-specific)
    deployRole.addToPolicy(new iam.PolicyStatement({
      actions: ['ecr:GetAuthorizationToken'],
      resources: ['*'],
    }));

    // ECR: push to the backend repository only
    deployRole.addToPolicy(new iam.PolicyStatement({
      actions: [
        'ecr:BatchCheckLayerAvailability',
        'ecr:PutImage',
        'ecr:InitiateLayerUpload',
        'ecr:UploadLayerPart',
        'ecr:CompleteLayerUpload',
        'ecr:DescribeRepositories',
        'ecr:ListImages',
        'ecr:DescribeImages',
      ],
      resources: [this.backendEcr.repositoryArn],
    }));

    // ECS: force a new deployment after pushing the image
    deployRole.addToPolicy(new iam.PolicyStatement({
      actions: [
        'ecs:UpdateService',
        'ecs:DescribeServices',
        'ecs:DescribeTaskDefinition',
        'ecs:RegisterTaskDefinition',
        'ecs:ListTaskDefinitions',
      ],
      resources: [
        service.serviceArn,
        `arn:aws:ecs:${this.region}:${this.account}:task-definition/wecircle-backend:*`,
      ],
    }));

    // IAM: pass task + execution roles when registering a new task definition
    deployRole.addToPolicy(new iam.PolicyStatement({
      actions: ['iam:PassRole'],
      resources: [taskRole.roleArn, executionRole.roleArn],
    }));

    // ── Stack outputs ─────────────────────────────────────────────────────
    new cdk.CfnOutput(this, 'AlbDnsName', {
      value: alb.loadBalancerDnsName,
      description: 'Point api.wecircle.helpers-tech.com CNAME here after validation',
    });
    new cdk.CfnOutput(this, 'BackendEcrUri', {
      value: this.backendEcr.repositoryUri,
      description: 'Push backend images here before the ECS service can start',
    });
    new cdk.CfnOutput(this, 'DeployRoleArn', {
      value: deployRole.roleArn,
      description: 'Replace AWS_ACCESS_KEY_ID/SECRET in GitHub secrets with this ARN (AWS_ROLE_ARN)',
    });
    new cdk.CfnOutput(this, 'ClusterName', {
      value: this.cluster.clusterName,
    });
  }
}
