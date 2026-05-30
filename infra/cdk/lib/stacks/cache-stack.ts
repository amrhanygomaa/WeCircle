import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as elasticache from 'aws-cdk-lib/aws-elasticache';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';

interface CacheStackProps extends cdk.StackProps {
  vpc: ec2.Vpc;
  redisSg: ec2.SecurityGroup;
}

/**
 * WeCircle ElastiCache Redis 7 — Socket.IO adapter (R7).
 *
 * Replaces the current in-process Socket.IO state so the backend can run
 * as multiple ECS tasks without losing realtime events between instances.
 *
 * Topology: primary + 1 replica across the 2 isolated AZs.
 * Transit encryption required; at-rest encryption enabled.
 *
 * After deploy:
 *   1. SSM /wecircle/REDIS_URL is auto-populated with the TLS endpoint.
 *   2. Set cacheDeployed: true in cdk.json context.
 *   3. Redeploy WeCircleCompute — it adds REDIS_URL to the ECS task env.
 *   4. The backend picks up the adapter automatically on next task restart.
 */
export class CacheStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: CacheStackProps) {
    super(scope, id, props);

    // Subnet group — isolated subnets, no internet route.
    const subnetGroup = new elasticache.CfnSubnetGroup(this, 'SubnetGroup', {
      description: 'WeCircle ElastiCache Redis - isolated subnets',
      cacheSubnetGroupName: 'wecircle-redis-subnet-group',
      subnetIds: props.vpc.isolatedSubnets.map(s => s.subnetId),
    });

    // Redis 7 ReplicationGroup: primary + 1 replica, Multi-AZ.
    // cache.t4g.small: ~$0.03/hr per node, adequate for Socket.IO message relay.
    const redis = new elasticache.CfnReplicationGroup(this, 'Redis', {
      replicationGroupDescription: 'WeCircle Socket.IO adapter',
      replicationGroupId: 'wecircle-redis',
      engine: 'redis',
      engineVersion: '7.1',
      cacheNodeType: 'cache.t4g.small',
      numCacheClusters: 2,                // primary + 1 replica
      automaticFailoverEnabled: true,
      multiAzEnabled: true,
      atRestEncryptionEnabled: true,
      transitEncryptionEnabled: true,
      transitEncryptionMode: 'required',  // enforce TLS — use rediss:// in client
      cacheSubnetGroupName: subnetGroup.ref,
      securityGroupIds: [props.redisSg.securityGroupId],
      snapshotRetentionLimit: 1,
      snapshotWindow: '03:30-04:30',
    });

    redis.addDependency(subnetGroup);

    // Store the primary endpoint in SSM so WeCircleCompute can read it.
    // Format: rediss://<host>:<port>  (TLS — double-s scheme)
    new ssm.StringParameter(this, 'RedisUrlParam', {
      parameterName: '/wecircle/REDIS_URL',
      stringValue: cdk.Fn.join('', [
        'rediss://',
        redis.attrPrimaryEndPointAddress,
        ':',
        redis.attrPrimaryEndPointPort,
      ]),
      description: 'WeCircle ElastiCache Redis TLS endpoint for Socket.IO adapter',
    });

    new cdk.CfnOutput(this, 'RedisEndpoint', {
      value: redis.attrPrimaryEndPointAddress,
      description: 'Update REDIS_URL SSM param if you point at this from another stack',
    });
    new cdk.CfnOutput(this, 'RedisPort', {
      value: redis.attrPrimaryEndPointPort,
    });
  }
}
