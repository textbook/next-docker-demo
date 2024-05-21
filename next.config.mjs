/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    ignoreDuringBuilds: process.env.NEXT_ESLINT_DISABLED === "1",
  },
  output: "standalone",
};

export default nextConfig;
