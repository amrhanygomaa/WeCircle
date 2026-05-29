import { Request, Response } from "express";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { env } from "../../config/env";
import { asyncHandler } from "../../core/utils/asyncHandler";

const s3Client = new S3Client({
  region: env.awsRegion,
  // Note: For EC2, AWS credentials are automatically picked up from IAM roles or env vars.
});

export const getPresignedUrl = asyncHandler(async (req: Request, res: Response) => {
  const { fileName, fileType, folder = "uploads" } = req.query;

  if (!fileName || !fileType) {
    return res.status(400).json({ success: false, message: "fileName and fileType are required" });
  }

  const key = `${folder}/${Date.now()}_${fileName}`;
  const bucketName = env.awsS3BucketName;

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: key,
    ContentType: String(fileType),
    // Optional: Add ACL if needed, but modern S3 buckets prefer Object Ownership.
    // ACL: "public-read", 
  });

  try {
    const presignedUrl = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
    
    // Construct the public URL assuming the bucket has public read access or a CloudFront distribution
    const publicUrl = `https://${bucketName}.s3.${env.awsRegion}.amazonaws.com/${key}`;

    res.json({
      success: true,
      presignedUrl,
      publicUrl,
      key
    });
  } catch (error: any) {
    console.error("S3 Presign Error:", error);
    res.status(500).json({ success: false, message: "Failed to generate upload URL" });
  }
});
