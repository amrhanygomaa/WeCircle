import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

/**
 * WeCircle networking layer.
 *
 * Topology (2 AZs, us-east-1a/b):
 *   Public  subnets  → ALB, NAT Gateways
 *   Private subnets  → ECS Fargate tasks (egress via NAT)
 *   Isolated subnets → RDS, ElastiCache (no internet route)
 *
 * Security group rules enforce strict least-privilege:
 *   internet → ALB → backend (5001) → RDS (5432) / Redis (6379)
 */
export class NetworkStack extends cdk.Stack {
  readonly vpc: ec2.Vpc;
  readonly albSg: ec2.SecurityGroup;
  readonly backendSg: ec2.SecurityGroup;
  readonly rdsSg: ec2.SecurityGroup;
  // Provisioned here so the future ECS + ElastiCache stacks can import it.
  readonly redisSg: ec2.SecurityGroup;

  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    // ── VPC ──────────────────────────────────────────────────────────────
    this.vpc = new ec2.Vpc(this, 'Vpc', {
      ipAddresses: ec2.IpAddresses.cidr('10.0.0.0/16'),
      maxAzs: 2,
      // Single NAT Gateway saves ~$32/month vs 2.
      // Upgrade to natGateways: 2 before a Phase 5 cutover that needs HA.
      natGateways: 1,
      subnetConfiguration: [
        {
          name: 'Public',
          subnetType: ec2.SubnetType.PUBLIC,
          cidrMask: 24,
        },
        {
          name: 'Private',
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
          cidrMask: 24,
        },
        {
          name: 'Isolated',
          subnetType: ec2.SubnetType.PRIVATE_ISOLATED,
          cidrMask: 24,
        },
      ],
    });

    // ── Security groups ──────────────────────────────────────────────────

    // ALB: accepts HTTP + HTTPS from the public internet.
    this.albSg = new ec2.SecurityGroup(this, 'AlbSg', {
      vpc: this.vpc,
      description: 'WeCircle ALB - internet-facing',
      allowAllOutbound: true,
    });
    this.albSg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(80),  'HTTP');
    this.albSg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(443), 'HTTPS');
    this.albSg.addIngressRule(ec2.Peer.anyIpv6(), ec2.Port.tcp(80),  'HTTP IPv6');
    this.albSg.addIngressRule(ec2.Peer.anyIpv6(), ec2.Port.tcp(443), 'HTTPS IPv6');

    // Backend (ECS Fargate): only accepts traffic from the ALB on port 5001.
    // Allows all outbound so tasks can reach ECR, Secrets Manager, S3, Cognito,
    // and external APIs (Gemini, Zoom, ip-api) via the NAT Gateway.
    this.backendSg = new ec2.SecurityGroup(this, 'BackendSg', {
      vpc: this.vpc,
      description: 'WeCircle ECS backend tasks',
      allowAllOutbound: true,
    });
    this.backendSg.addIngressRule(this.albSg, ec2.Port.tcp(5001), 'From ALB');

    // RDS: only accepts Postgres connections from the backend tasks.
    this.rdsSg = new ec2.SecurityGroup(this, 'RdsSg', {
      vpc: this.vpc,
      description: 'WeCircle RDS PostgreSQL',
      allowAllOutbound: false,
    });
    this.rdsSg.addIngressRule(this.backendSg, ec2.Port.tcp(5432), 'From ECS backend');

    // ElastiCache Redis: provisioned now so later stacks can reference this SG
    // without a circular dependency. Used in the upcoming ECS + Redis stack.
    this.redisSg = new ec2.SecurityGroup(this, 'RedisSg', {
      vpc: this.vpc,
      description: 'WeCircle ElastiCache Redis',
      allowAllOutbound: false,
    });
    this.redisSg.addIngressRule(this.backendSg, ec2.Port.tcp(6379), 'From ECS backend');

    // ── Stack outputs ────────────────────────────────────────────────────
    new cdk.CfnOutput(this, 'VpcId', {
      value: this.vpc.vpcId,
    });
    new cdk.CfnOutput(this, 'BackendSgId', {
      value: this.backendSg.securityGroupId,
      description: 'Attach to ECS task networkConfiguration.awsvpcConfiguration',
    });
    new cdk.CfnOutput(this, 'RdsSgId', {
      value: this.rdsSg.securityGroupId,
    });
  }
}
