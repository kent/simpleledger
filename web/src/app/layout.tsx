import { type Metadata, type Viewport } from 'next'
import { Manrope } from 'next/font/google'
import clsx from 'clsx'

import { appStoreId, siteUrl } from '@/lib/site'
import '@/styles/tailwind.css'

const manrope = Manrope({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-manrope',
})

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#10B981',
}

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    template: '%s | Munnies',
    default: 'Munnies | Family Money Accounts for Allowance, Chores, and Spending',
  },
  description:
    'Munnies helps families track allowance, chores, gifts, and spending in simple shared accounts for each child. Sync with iCloud, invite family, and pay once.',
  applicationName: 'Munnies',
  keywords: [
    'allowance tracker',
    'kids money app',
    'family allowance app',
    'kids spending tracker',
    'chore tracker',
    'money accounts for kids',
    'family finance app',
    'one time purchase app',
    'iCloud family sharing app',
    'allowance app for parents',
  ],
  authors: [{ name: 'Munnies' }],
  creator: 'Munnies',
  publisher: 'Munnies',
  formatDetection: {
    telephone: false,
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: siteUrl,
    siteName: 'Munnies',
    title: 'Munnies | Shared Family Money Accounts Without the Subscription',
    description:
      'Track allowance, chores, gifts, and spending in private iCloud-backed family accounts for each child.',
    images: [
      {
        url: '/munnies-mark.png',
        width: 1024,
        height: 1024,
        alt: 'Munnies app icon',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Munnies | Family Money Accounts Without the Subscription',
    description:
      'Keep kid accounts organized across iPhone and iPad, sync with iCloud, and pay once.',
    images: ['/munnies-mark.png'],
  },
  appleWebApp: {
    capable: true,
    title: 'Munnies',
    statusBarStyle: 'black-translucent',
  },
  itunes: {
    appId: appStoreId,
  },
  category: 'finance',
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'P2leN9QSSuL2pdXpqe5-JLyw-Dw_-VMriBKpnDNRbcw',
  },
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: 'any' },
      { url: '/icon-192.png', type: 'image/png', sizes: '192x192' },
      { url: '/icon-512.png', type: 'image/png', sizes: '512x512' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
    ],
  },
  manifest: '/manifest.json',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={clsx('bg-gray-50 antialiased', manrope.variable)}>
      <head>
        <link rel="canonical" href={siteUrl} />
        <meta name="apple-itunes-app" content={`app-id=${appStoreId}`} />
      </head>
      <body>{children}</body>
    </html>
  )
}
