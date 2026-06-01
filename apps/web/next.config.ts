import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  transpilePackages: ['@capcard/editor-engine', '@capcard/api-sdk'],
  experimental: {
    optimizePackageImports: ['lucide-react', '@radix-ui/react-dialog', '@radix-ui/react-tabs'],
  },
}

export default nextConfig
