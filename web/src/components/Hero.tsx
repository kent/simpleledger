'use client'

import { useId } from 'react'

import { AppStoreLink } from '@/components/AppStoreLink'
import { Container } from '@/components/Container'
import { PhoneFrame } from '@/components/PhoneFrame'
import { AppScreenMockup } from '@/components/AppScreenMockup'

function BackgroundIllustration(props: React.ComponentPropsWithoutRef<'div'>) {
  let id = useId()

  return (
    <div {...props}>
      <svg
        viewBox="0 0 1026 1026"
        fill="none"
        aria-hidden="true"
        className="absolute inset-0 h-full w-full animate-spin-slow"
      >
        <path
          d="M1025 513c0 282.77-229.23 512-512 512S1 795.77 1 513 230.23 1 513 1s512 229.23 512 512Z"
          stroke="#D4D4D4"
          strokeOpacity="0.7"
        />
        <path
          d="M513 1025C230.23 1025 1 795.77 1 513"
          stroke={`url(#${id}-gradient-1)`}
          strokeLinecap="round"
        />
        <defs>
          <linearGradient
            id={`${id}-gradient-1`}
            x1="1"
            y1="513"
            x2="1"
            y2="1025"
            gradientUnits="userSpaceOnUse"
          >
            <stop stopColor="#10B981" />
            <stop offset="1" stopColor="#10B981" stopOpacity="0" />
          </linearGradient>
        </defs>
      </svg>
      <svg
        viewBox="0 0 1026 1026"
        fill="none"
        aria-hidden="true"
        className="absolute inset-0 h-full w-full animate-spin-reverse-slower"
      >
        <path
          d="M913 513c0 220.914-179.086 400-400 400S113 733.914 113 513s179.086-400 400-400 400 179.086 400 400Z"
          stroke="#D4D4D4"
          strokeOpacity="0.7"
        />
        <path
          d="M913 513c0 220.914-179.086 400-400 400"
          stroke={`url(#${id}-gradient-2)`}
          strokeLinecap="round"
        />
        <defs>
          <linearGradient
            id={`${id}-gradient-2`}
            x1="913"
            y1="513"
            x2="913"
            y2="913"
            gradientUnits="userSpaceOnUse"
          >
            <stop stopColor="#10B981" />
            <stop offset="1" stopColor="#10B981" stopOpacity="0" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  )
}

export function Hero() {
  return (
    <div className="overflow-hidden py-20 sm:py-32 lg:pb-32 xl:pb-36">
      <Container>
        <div className="lg:grid lg:grid-cols-12 lg:gap-x-8 lg:gap-y-20">
          <div className="relative z-10 mx-auto max-w-2xl lg:col-span-7 lg:max-w-none lg:pt-6 xl:col-span-6">
            <h1 className="text-4xl font-medium tracking-tight text-gray-900 sm:text-5xl">
              Goodbye IOU napkins. <br />
              <span className="text-emerald-600">Hello Munnies.</span>
            </h1>
            <p className="mt-6 text-lg text-gray-600">
              Remember promising Emma $5 for cleaning her room? Neither do we.
              That&apos;s why we built Munnies &mdash; the ridiculously simple app that
              tracks allowances, chore money, and birthday cash so you don&apos;t have to
              remember a thing.
            </p>
            <div className="mt-8 flex flex-wrap gap-x-6 gap-y-4">
              <AppStoreLink />
              <div className="flex items-center gap-2 text-sm text-gray-500">
                <span className="text-lg">🎉</span>
                <span>100% free, forever</span>
              </div>
            </div>
          </div>
          <div className="relative mt-10 sm:mt-20 lg:col-span-5 lg:row-span-2 lg:mt-0 xl:col-span-6">
            <BackgroundIllustration className="absolute top-4 left-1/2 h-[1026px] w-[1026px] -translate-x-1/3 mask-[linear-gradient(to_bottom,white_20%,transparent_75%)] stroke-gray-300/70 sm:top-16 sm:-translate-x-1/2 lg:-top-16 lg:ml-12 xl:-top-14 xl:ml-0" />
            <div className="-mx-4 h-[448px] mask-[linear-gradient(to_bottom,white_60%,transparent)] px-9 sm:mx-0 lg:absolute lg:-inset-x-10 lg:-top-10 lg:-bottom-20 lg:h-auto lg:px-0 lg:pt-10 xl:-bottom-32">
              <PhoneFrame className="mx-auto max-w-[366px]">
                <AppScreenMockup />
              </PhoneFrame>
            </div>
          </div>
          <div className="relative -mt-4 lg:col-span-7 lg:mt-0 xl:col-span-6">
            <p className="text-center text-sm font-semibold text-gray-900 lg:text-left">
              Loved by real (tired) parents everywhere
            </p>
            <div className="mx-auto mt-8 flex max-w-xl flex-wrap justify-center gap-x-10 gap-y-6 lg:mx-0 lg:justify-start">
              <div className="flex items-center gap-2 rounded-full bg-emerald-50 px-4 py-2 text-gray-700">
                <span className="text-xl">⭐️</span>
                <span className="text-sm font-medium">4.9 stars</span>
              </div>
              <div className="flex items-center gap-2 rounded-full bg-blue-50 px-4 py-2 text-gray-700">
                <span className="text-xl">👨‍👩‍👧‍👦</span>
                <span className="text-sm font-medium">10k+ happy families</span>
              </div>
              <div className="flex items-center gap-2 rounded-full bg-purple-50 px-4 py-2 text-gray-700">
                <span className="text-xl">🔒</span>
                <span className="text-sm font-medium">Privacy first</span>
              </div>
              <div className="flex items-center gap-2 rounded-full bg-yellow-50 px-4 py-2 text-gray-700">
                <span className="text-xl">☁️</span>
                <span className="text-sm font-medium">iCloud synced</span>
              </div>
            </div>
          </div>
        </div>
      </Container>
    </div>
  )
}
