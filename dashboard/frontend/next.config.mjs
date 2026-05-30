/** @type {import('next').NextConfig} */
const nextConfig = {
  // Static export — outputs to out/ for S3 + CloudFront (WeCircleCdn stack).
  // next start is no longer valid after this change; serve out/ with a static server.
  output: 'export',
  reactStrictMode: true,
  transpilePackages: ['lucide-react', 'recharts'],
  images: {
    // Required for static export — Next.js image optimisation is server-only.
    unoptimized: true,
  },
};

export default nextConfig;
