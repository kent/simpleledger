import Image from 'next/image'

import { Container } from '@/components/Container'
import { PhoneFrame } from '@/components/PhoneFrame'

const features = [
  {
    name: 'Separate accounts for every child',
    eyebrow: 'Dashboard',
    description:
      'See balances at a glance, keep siblings separate, and stop trying to remember who got what last week.',
    image: '/screenshots/iphone-dashboard.png',
    alt: 'Dashboard with balances for multiple child accounts',
  },
  {
    name: 'Add allowance, chores, or gifts in seconds',
    eyebrow: 'Quick add',
    description:
      'Use fast amount buttons when payday hits, then add a note so everyone remembers where the money came from.',
    image: '/screenshots/iphone-add-money.png',
    alt: 'Add money screen with quick amount buttons',
  },
  {
    name: 'Check history before the next debate starts',
    eyebrow: 'History',
    description:
      'Every transaction stays visible, so birthday cash, spending, and corrections are easy to verify later.',
    image: '/screenshots/iphone-history.png',
    alt: 'Transaction history for a child account',
  },
]

export function PrimaryFeatures() {
  return (
    <section
      id="features"
      aria-label="Core Munnies features"
      className="relative overflow-hidden bg-gray-900 py-20 sm:py-32"
    >
      <Container className="relative">
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold tracking-[0.2em] text-orange-300 uppercase">
            What Makes It Easy
          </p>
          <h2 className="mt-4 text-3xl font-medium tracking-tight text-white sm:text-4xl">
            Built around the moments families actually need.
          </h2>
          <p className="mt-4 text-lg text-gray-300">
            Munnies keeps balances clear, updates fast, and shared accounts calm.
            No setup maze, no web dashboard, and no subscription to justify.
          </p>
        </div>
        <div className="mt-16 grid gap-8 lg:grid-cols-3">
          {features.map((feature) => (
            <article
              key={feature.name}
              className="rounded-3xl border border-white/10 bg-white/5 p-6 shadow-2xl shadow-black/10 backdrop-blur"
            >
              <p className="text-sm font-semibold tracking-wide text-orange-300 uppercase">
                {feature.eyebrow}
              </p>
              <h3 className="mt-3 text-xl font-semibold text-white">
                {feature.name}
              </h3>
              <p className="mt-3 text-sm leading-7 text-gray-300">
                {feature.description}
              </p>
              <div className="mt-8">
                <PhoneFrame className="mx-auto max-w-[290px]">
                  <Image
                    src={feature.image}
                    alt={feature.alt}
                    width={1320}
                    height={2868}
                    className="h-full w-full object-cover"
                  />
                </PhoneFrame>
              </div>
            </article>
          ))}
        </div>
      </Container>
    </section>
  )
}
