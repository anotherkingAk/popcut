import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  output: 'export',
  transpilePackages: ['@popcut/editor-engine', '@popcut/api-sdk'],
  experimental: {
    optimizePackageImports: ['lucide-react', '@radix-ui/react-dialog', '@radix-ui/react-tabs'],
  },
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.popcut.com' },
      { protocol: 'https', hostname: '**.cloudflare.com' },
    ],
  },
}

export default nextConfig
