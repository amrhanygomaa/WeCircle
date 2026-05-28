# AWS Integration & DevOps

WeCircle runs entirely on AWS.

## Architecture Map

- **Frontend Dashboard:** Built as static exports via Next.js and deployed to an S3 bucket configured for static web hosting.
- **Backend API:** A Node.js monolithic service running on Amazon EC2 (Free Tier eligible t2.micro / t3.micro).
- **Database:** PostgreSQL running securely on the EC2 instance (or RDS Free Tier).
- **Mobile:** Flutter application shipped to stores, pointing strictly to the AWS EC2 Elastic IP.

## CI/CD Playbook for AI Agents

When prompted to "deploy to AWS", execute the following steps:

1. Ensure the Node.js backend uses `npm ci` and builds correctly (`npm run build`).
2. SSH into the EC2 instance using the stored private key.
3. Use a deployment script via SSH to execute `git pull`, `npm install`, `npx prisma db push`, and `pm2 restart`.
4. Ensure environment variables are loaded on the EC2 server (`/opt/wecircle/dashboard/backend/.env`).

## AWS Free Tier Restrictions

The AI agent must never provision resources that fall outside the Free Tier boundaries.

- **Compute:** Only `t2.micro` or `t3.micro`.
- **Storage:** Only `EBS General Purpose (SSD) up to 30 GB` or `S3 Standard up to 5 GB`.
- **Database:** Only `RDS db.t3.micro` or EC2 native pgsql.

Always double-check `aws_account_memory.md` before making infrastructure calls.
