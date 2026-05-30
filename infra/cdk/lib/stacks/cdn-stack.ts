import * as cdk from 'aws-cdk-lib';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';

/**
 * WeCircle frontend CDN — S3 + CloudFront.
 *
 * Serves the Next.js static export (next build → out/) via CloudFront.
 * The S3 bucket is private; CloudFront accesses it via Origin Access Control.
 *
 * After deploy:
 *   1. Update next.config.mjs: add  output: 'export'
 *   2. Update CI frontend build step to sync out/ to FrontendBucketName output.
 *   3. Point wecircle.helpers-tech.com CNAME → CloudFrontDomain output.
 *   4. For custom domain + HTTPS, create an ACM cert in us-east-1, then:
 *        cdk deploy -c frontendCertificateArn=arn:aws:acm:us-east-1:...
 */
export class CdnStack extends cdk.Stack {
  readonly bucket: s3.Bucket;
  readonly distribution: cloudfront.Distribution;

  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    // ── S3 bucket ─────────────────────────────────────────────────────────
    this.bucket = new s3.Bucket(this, 'FrontendBucket', {
      bucketName: `wecircle-frontend-${this.account}`,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
      versioned: false,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    // ── CloudFront ────────────────────────────────────────────────────────
    // Optional ACM cert for custom domain (must be in us-east-1 for CloudFront).
    // Pass via: cdk deploy -c frontendCertificateArn=arn:aws:acm:us-east-1:...
    const certArn = this.node.tryGetContext('frontendCertificateArn') as string | undefined;

    const domainProps: Partial<cloudfront.DistributionProps> = certArn
      ? {
          domainNames: ['wecircle.helpers-tech.com'],
          certificate: acm.Certificate.fromCertificateArn(this, 'FrontendCert', certArn),
        }
      : {};

    this.distribution = new cloudfront.Distribution(this, 'Distribution', {
      ...domainProps,
      defaultBehavior: {
        origin: origins.S3BucketOrigin.withOriginAccessControl(this.bucket),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
        compress: true,
      },
      defaultRootObject: 'index.html',
      // App Router SPA: unknown paths and 403 from S3 fall back to index.html.
      // The client-side router handles routing; TTL=0 prevents stale 200 caching.
      errorResponses: [
        {
          httpStatus: 403,
          responsePagePath: '/index.html',
          responseHttpStatus: 200,
          ttl: cdk.Duration.seconds(0),
        },
        {
          httpStatus: 404,
          responsePagePath: '/index.html',
          responseHttpStatus: 200,
          ttl: cdk.Duration.seconds(0),
        },
      ],
      priceClass: cloudfront.PriceClass.PRICE_CLASS_100, // US + Europe only — cheapest
      comment: 'WeCircle frontend — Next.js static export',
    });

    // ── Outputs ───────────────────────────────────────────────────────────
    new cdk.CfnOutput(this, 'FrontendBucketName', {
      value: this.bucket.bucketName,
      description: 'aws s3 sync out/ s3://<bucket> --delete',
    });
    new cdk.CfnOutput(this, 'CloudFrontDistributionId', {
      value: this.distribution.distributionId,
      description: 'aws cloudfront create-invalidation --distribution-id <id> --paths "/*"',
    });
    new cdk.CfnOutput(this, 'CloudFrontDomain', {
      value: this.distribution.distributionDomainName,
      description: 'Point wecircle.helpers-tech.com CNAME here',
    });
  }
}
