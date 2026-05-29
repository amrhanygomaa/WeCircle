const { CognitoIdentityProviderClient, CreateUserPoolCommand, CreateUserPoolClientCommand } = require('@aws-sdk/client-cognito-identity-provider');
const { S3Client, CreateBucketCommand, PutBucketCorsCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');

const REGION = 'us-east-1'; // Defaulting to us-east-1 for free tier

const cognitoClient = new CognitoIdentityProviderClient({
  region: REGION
});

const s3Client = new S3Client({
  region: REGION
});

async function provision() {
  try {
    console.log("Creating Cognito User Pool...");
    const poolRes = await cognitoClient.send(new CreateUserPoolCommand({
      PoolName: "WeCircleUserPool",
      AutoVerifiedAttributes: ["email"],
      Policies: {
        PasswordPolicy: {
          MinimumLength: 6,
          RequireUppercase: false,
          RequireLowercase: false,
          RequireNumbers: false,
          RequireSymbols: false,
        }
      },
      UsernameAttributes: ["email"],
      Schema: [
        {
          Name: "email",
          Required: true,
          Mutable: true,
        },
        {
          Name: "role",
          AttributeDataType: "String",
          Mutable: true,
        },
        {
          Name: "schoolId",
          AttributeDataType: "String",
          Mutable: true,
        }
      ]
    }));

    const userPoolId = poolRes.UserPool.Id;
    console.log("User Pool Created:", userPoolId);

    console.log("Creating User Pool Client...");
    const clientRes = await cognitoClient.send(new CreateUserPoolClientCommand({
      UserPoolId: userPoolId,
      ClientName: "WeCircleAppClient",
      GenerateSecret: false,
      ExplicitAuthFlows: ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
    }));

    const clientId = clientRes.UserPoolClient.ClientId;
    console.log("Client ID Created:", clientId);

    const bucketName = `wecircle-storage-${Date.now()}`;
    console.log(`Creating S3 Bucket: ${bucketName}...`);
    
    await s3Client.send(new CreateBucketCommand({
      Bucket: bucketName,
    }));
    console.log("S3 Bucket Created.");

    console.log("Configuring CORS for S3...");
    await s3Client.send(new PutBucketCorsCommand({
      Bucket: bucketName,
      CORSConfiguration: {
        CORSRules: [
          {
            AllowedHeaders: ["*"],
            AllowedMethods: ["GET", "PUT", "POST", "DELETE", "HEAD"],
            AllowedOrigins: ["*"], // For development
            ExposeHeaders: []
          }
        ]
      }
    }));
    console.log("S3 CORS Configured.");

    const envContent = `NEXT_PUBLIC_AWS_REGION=${REGION}\nNEXT_PUBLIC_COGNITO_USER_POOL_ID=${userPoolId}\nNEXT_PUBLIC_COGNITO_CLIENT_ID=${clientId}\nAWS_S3_BUCKET_NAME=${bucketName}\n`;
    fs.writeFileSync('aws_config.txt', envContent);
    console.log("Provisioning Complete! Config written to aws_config.txt");

  } catch (error) {
    console.error("Error provisioning AWS:", error);
  }
}

provision();
