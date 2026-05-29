import { CognitoUserPool } from "amazon-cognito-identity-js";

const poolData = {
  UserPoolId: process.env.NEXT_PUBLIC_COGNITO_USER_POOL_ID || "",
  ClientId: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID || "",
};

export const isCognitoConfigured = Boolean(
  poolData.UserPoolId && 
  poolData.ClientId && 
  poolData.UserPoolId !== "your_user_pool_id"
);

export const userPool = new CognitoUserPool({
  UserPoolId: isCognitoConfigured ? poolData.UserPoolId : "us-east-1_placeholder",
  ClientId: isCognitoConfigured ? poolData.ClientId : "placeholderclientid"
});
