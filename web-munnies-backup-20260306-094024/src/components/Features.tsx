import { Container } from '@/components/Container'

const features = [
  {
    name: 'One kid? Five kids? No problem.',
    description:
      'Create a colorful ledger for each child with their own emoji and color. Because every kiddo deserves their own piggy bank.',
    emoji: '👧👦🧒',
  },
  {
    name: 'Tap-tap done.',
    description:
      'Add $1, $5, $10, or $20 with a single tap. Weekly allowance takes literally 2 seconds. We timed it.',
    emoji: '⚡️',
  },
  {
    name: 'Where did that $20 go?',
    description:
      'Full history with notes. Finally know that the birthday money went to Robux (again).',
    emoji: '🔍',
  },
  {
    name: 'Team parenting mode.',
    description:
      'Share ledgers with your partner, grandparents, or the babysitter. Everyone stays in the loop.',
    emoji: '👨‍👩‍👧',
  },
  {
    name: 'It just follows you.',
    description:
      'iCloud sync means your iPhone, iPad, and any other Apple device are always up to date. Like magic.',
    emoji: '✨',
  },
  {
    name: 'Confetti time!',
    description:
      'Big deposits get a celebration! Watch your kid\'s face light up when the confetti falls.',
    emoji: '🎊',
  },
]

export function Features() {
  return (
    <section
      id="features"
      aria-label="Features for tracking your kids' allowances"
      className="py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-2xl sm:text-center">
          <h2 className="text-3xl font-medium tracking-tight text-gray-900">
            Built by parents who forgot one too many allowances.
          </h2>
          <p className="mt-2 text-lg text-gray-600">
            We get it. Life is chaos. That&apos;s why Munnies does the remembering for you.
          </p>
        </div>
        <ul
          role="list"
          className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-6 text-sm sm:mt-20 sm:grid-cols-2 md:gap-y-10 lg:max-w-none lg:grid-cols-3"
        >
          {features.map((feature) => (
            <li
              key={feature.name}
              className="group rounded-2xl border border-gray-200 p-8 transition-colors hover:border-emerald-200 hover:bg-emerald-50/50"
            >
              <div className="text-4xl">{feature.emoji}</div>
              <h3 className="mt-6 font-semibold text-gray-900">
                {feature.name}
              </h3>
              <p className="mt-2 text-gray-700">{feature.description}</p>
            </li>
          ))}
        </ul>
      </Container>
    </section>
  )
}
