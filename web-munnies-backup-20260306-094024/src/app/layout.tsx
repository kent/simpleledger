import { type Metadata } from 'next'
import { Inter } from 'next/font/google'
import clsx from 'clsx'

import '@/styles/tailwind.css'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
})

export const metadata: Metadata = {
  metadataBase: new URL('https://munnies.app'),
  title: {
    template: '%s | Munnies',
    default: 'Munnies - Track Your Kids\' Allowance & Spending',
  },
  description:
    'Munnies helps parents easily track allowances, chore earnings, and spending for each child. Share ledgers with family, sync across devices, and teach kids about money.',
  keywords: [
    'kids allowance tracker',
    'children money management',
    'family finance app',
    'allowance app for parents',
    'kids spending tracker',
    'chore money tracker',
    'family budget app',
    'teach kids about money',
    'allowance manager',
    'kids piggy bank app',
  ],
  authors: [{ name: 'Munnies' }],
  creator: 'Munnies',
  publisher: 'Munnies',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://munnies.app',
    siteName: 'Munnies',
    title: 'Munnies - Track Your Kids\' Allowance & Spending',
    description:
      'The easiest way for parents to track allowances, gifts, and spending for each child. Share with family and sync across all your devices.',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Munnies - Family Allowance Tracker',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Munnies - Track Your Kids\' Allowance & Spending',
    description:
      'The easiest way for parents to track allowances, gifts, and spending for each child.',
    images: ['/og-image.png'],
  },
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
  alternates: {
    canonical: 'https://munnies.app',
  },
  category: 'finance',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={clsx('bg-gray-50 antialiased', inter.variable)}>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <meta name="apple-itunes-app" content="app-id=YOUR_APP_ID" />
      </head>
      <body>{children}</body>
    </html>
  )
}
