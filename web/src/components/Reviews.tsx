import Image from 'next/image'

import { Container } from '@/components/Container'

const screens = [
  {
    title: 'Dashboard on iPhone',
    body: 'The home screen keeps each child account visible, colorful, and easy to scan.',
    image: '/screenshots/iphone-dashboard.png',
    alt: 'iPhone dashboard for multiple child accounts',
  },
  {
    title: 'Account view on iPad',
    body: 'The iPad layout gives you a bigger balance and transaction view when you want more context.',
    image: '/screenshots/ipad-accounts.png',
    alt: 'iPad view of a child account balance and transactions',
  },
  {
    title: 'Quick add flow',
    body: 'Allowance, chores, or gifts can be added with fast amount buttons and an optional note.',
    image: '/screenshots/iphone-add-money.png',
    alt: 'iPhone add money screen',
  },
  {
    title: 'History on iPad',
    body: 'Older transactions stay visible so spending and corrections are easy to audit later.',
    image: '/screenshots/ipad-history.png',
    alt: 'iPad transaction history screen',
  },
]

export function Reviews() {
  return (
    <section
      id="screens"
      aria-labelledby="screens-title"
      className="border-t border-gray-200 py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold tracking-[0.2em] text-orange-700 uppercase">
            See The App
          </p>
          <h2
            id="screens-title"
            className="mt-4 text-3xl font-medium tracking-tight text-gray-900 sm:text-4xl"
          >
            Real Munnies screens on iPhone and iPad.
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            These are the same screenshots being used for the App Store listing,
            so the site and store page tell the same story.
          </p>
        </div>
        <div className="mt-16 grid gap-8 lg:grid-cols-2">
          {screens.map((screen) => (
            <article
              key={screen.title}
              className="overflow-hidden rounded-3xl border border-gray-200 bg-white shadow-sm shadow-gray-900/5"
            >
              <div className="bg-linear-to-br from-orange-50 to-white p-4">
                <Image
                  src={screen.image}
                  alt={screen.alt}
                  width={2064}
                  height={2868}
                  className="h-auto w-full rounded-2xl border border-gray-200 bg-white"
                />
              </div>
              <div className="p-6">
                <h3 className="text-lg font-semibold text-gray-900">
                  {screen.title}
                </h3>
                <p className="mt-2 text-sm leading-7 text-gray-600">
                  {screen.body}
                </p>
              </div>
            </article>
          ))}
        </div>
      </Container>
    </section>
  )
}
