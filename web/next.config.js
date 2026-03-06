/** @type {import('next').NextConfig} */
const shortSharedCache = 'public, max-age=0, s-maxage=900, stale-while-revalidate=3600'
const mediumSharedCache = 'public, max-age=0, s-maxage=3600, stale-while-revalidate=86400'
const immutableAssetCache = 'public, max-age=31536000, immutable'

const nextConfig = {
  async headers() {
    return [
      {
        source: '/',
        headers: [{ key: 'Cache-Control', value: shortSharedCache }],
      },
      {
        source: '/privacy',
        headers: [{ key: 'Cache-Control', value: shortSharedCache }],
      },
      {
        source: '/terms',
        headers: [{ key: 'Cache-Control', value: shortSharedCache }],
      },
      {
        source: '/support',
        headers: [{ key: 'Cache-Control', value: shortSharedCache }],
      },
      {
        source: '/sitemap.xml',
        headers: [{ key: 'Cache-Control', value: mediumSharedCache }],
      },
      {
        source: '/robots.txt',
        headers: [{ key: 'Cache-Control', value: mediumSharedCache }],
      },
      {
        source: '/manifest.json',
        headers: [{ key: 'Cache-Control', value: mediumSharedCache }],
      },
      {
        source: '/screenshots/:path*',
        headers: [{ key: 'Cache-Control', value: immutableAssetCache }],
      },
      {
        source: '/munnies-mark.png',
        headers: [{ key: 'Cache-Control', value: immutableAssetCache }],
      },
      {
        source: '/icon-192.png',
        headers: [{ key: 'Cache-Control', value: immutableAssetCache }],
      },
      {
        source: '/icon-512.png',
        headers: [{ key: 'Cache-Control', value: immutableAssetCache }],
      },
      {
        source: '/apple-touch-icon.png',
        headers: [{ key: 'Cache-Control', value: immutableAssetCache }],
      },
    ]
  },
}

module.exports = nextConfig
