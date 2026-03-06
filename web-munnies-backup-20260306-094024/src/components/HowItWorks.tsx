import { Container } from '@/components/Container'

const steps = [
  {
    step: '1',
    emoji: '👶',
    title: 'Add your munchkins',
    description:
      'Create a ledger for each kid. Pick their favorite emoji and color. Takes 10 seconds, tops.',
  },
  {
    step: '2',
    emoji: '💸',
    title: 'Track the munnies',
    description:
      'Tap to add allowance, chore money, or Grandma\'s birthday check. Record spending just as easily.',
  },
  {
    step: '3',
    emoji: '🎯',
    title: 'Never forget again',
    description:
      'Munnies remembers everything. Check balances anytime. Share with your co-parent. Done and done.',
  },
]

export function HowItWorks() {
  return (
    <section
      id="how-it-works"
      aria-label="How Munnies works"
      className="bg-gray-900 py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-2xl sm:text-center">
          <h2 className="text-3xl font-medium tracking-tight text-white">
            Easier than making a PB&amp;J. <br className="hidden sm:inline" />
            <span className="text-emerald-400">Seriously.</span>
          </h2>
          <p className="mt-2 text-lg text-gray-400">
            If you can tap a button, you can use Munnies. No learning curve, no complicated setup, no headaches.
          </p>
        </div>
        <div className="mx-auto mt-16 max-w-5xl sm:mt-20">
          <div className="grid grid-cols-1 gap-12 md:grid-cols-3 md:gap-8">
            {steps.map((item, index) => (
              <div key={item.step} className="relative text-center md:text-left">
                {/* Connector line on desktop */}
                {index < steps.length - 1 && (
                  <div className="absolute top-6 left-1/2 hidden h-0.5 w-full bg-gradient-to-r from-emerald-500/50 to-transparent md:block" />
                )}
                <div className="relative inline-flex h-12 w-12 items-center justify-center rounded-full bg-emerald-500 text-2xl">
                  {item.emoji}
                </div>
                <h3 className="mt-6 text-lg font-semibold text-white">
                  {item.title}
                </h3>
                <p className="mt-2 text-gray-400">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </Container>
    </section>
  )
}
