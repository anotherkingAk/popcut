import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  transpilePackages: ['@popcut/api-sdk'],
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
}

export default nextConfig
