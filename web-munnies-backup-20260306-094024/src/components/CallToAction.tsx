import { AppStoreLink } from '@/components/AppStoreLink'
import { CircleBackground } from '@/components/CircleBackground'
import { Container } from '@/components/Container'

export function CallToAction() {
  return (
    <section
      id="download"
      className="relative overflow-hidden bg-gray-900 py-20 sm:py-28"
    >
      <div className="absolute top-1/2 left-20 -translate-y-1/2 sm:left-1/2 sm:-translate-x-1/2">
        <CircleBackground color="#fff" className="animate-spin-slower" />
      </div>
      <Container className="relative">
        <div className="mx-auto max-w-lg sm:text-center">
          <div className="mb-6 text-6xl">🎁</div>
          <h2 className="text-3xl font-medium tracking-tight text-white sm:text-4xl">
            Your kids&apos; financial future starts with one tap.
          </h2>
          <p className="mt-4 text-lg text-gray-300">
            Download Munnies and join 10,000+ families who are teaching their kids
            about money the easy way. It&apos;s a simple one-time purchase with no subscription.
          </p>
          <div className="mt-8 flex flex-col items-center gap-4">
            <AppStoreLink color="white" />
            <p className="text-sm text-gray-400">
              $1.99 one time • No subscription • No account needed
            </p>
          </div>
        </div>
      </Container>
    </section>
  )
}
