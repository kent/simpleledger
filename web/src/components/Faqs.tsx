import { Container } from '@/components/Container'

const faqs = [
  [
    {
      question: 'Wait, it\'s really free?',
      answer:
        'Yep! 100% free. No sneaky subscriptions, no in-app purchases, no "premium" tier. We made this for our own families and wanted to share it with everyone.',
    },
    {
      question: 'Will it sync between me and my partner?',
      answer:
        'You bet! Share any ledger with family members. You can both add money, track spending, and see the same balances. No more "I thought YOU gave her the allowance" arguments.',
    },
    {
      question: 'What about our privacy?',
      answer:
        'Your data never leaves your iCloud. We literally can\'t see it even if we wanted to. Privacy is baked in, not bolted on.',
    },
  ],
  [
    {
      question: 'How many kids can I add?',
      answer:
        'As many as you need! Got a basketball team\'s worth of kids? No problem. Each one gets their own ledger.',
    },
    {
      question: 'Can Grandma use it too?',
      answer:
        'Absolutely! Share ledgers with grandparents, aunts, uncles, or anyone else who spoils... er, helps with your kids\' finances.',
    },
    {
      question: 'What if my kid spends money?',
      answer:
        'Just hit the "Spend" mode and record it. You can add notes like "candy store raid" or "mystery purchase" so you remember later.',
    },
  ],
  [
    {
      question: 'Does it work on iPad too?',
      answer:
        'Yes! Munnies syncs across all your Apple devices via iCloud. Update on your phone, check on your iPad, or vice versa.',
    },
    {
      question: 'Can I add notes to transactions?',
      answer:
        'For sure! Add notes like "Birthday $$ from Uncle Bob" or "Spent on something probably Roblox-related." The history is all there.',
    },
    {
      question: 'What if I need help?',
      answer:
        'Drop us a line at support@munnies.app! We\'re real humans (and parents) who actually read every message.',
    },
  ],
]

export function Faqs() {
  return (
    <section
      id="faqs"
      aria-labelledby="faqs-title"
      className="border-t border-gray-200 py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-2xl lg:mx-0">
          <h2
            id="faqs-title"
            className="text-3xl font-medium tracking-tight text-gray-900"
          >
            Questions? We got answers. 💬
          </h2>
          <p className="mt-2 text-lg text-gray-600">
            Still curious?{' '}
            <a
              href="mailto:support@munnies.app"
              className="text-emerald-600 underline hover:text-emerald-500"
            >
              Shoot us an email
            </a>
            . We promise we&apos;re friendly.
          </p>
        </div>
        <ul
          role="list"
          className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:max-w-none lg:grid-cols-3"
        >
          {faqs.map((column, columnIndex) => (
            <li key={columnIndex}>
              <ul role="list" className="space-y-10">
                {column.map((faq, faqIndex) => (
                  <li key={faqIndex}>
                    <h3 className="text-lg/6 font-semibold text-gray-900">
                      {faq.question}
                    </h3>
                    <p className="mt-4 text-sm text-gray-700">{faq.answer}</p>
                  </li>
                ))}
              </ul>
            </li>
          ))}
        </ul>
      </Container>
    </section>
  )
}
