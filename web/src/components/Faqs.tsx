import { Container } from '@/components/Container'

const faqs = [
  [
    {
      question: 'Is there a subscription?',
      answer:
        'No. Munnies is a one-time purchase for $1.99 on the App Store. There is no monthly plan, premium tier, or recurring fee.',
    },
    {
      question: 'Can multiple family members use the same accounts?',
      answer:
        'Yes. You can share accounts through iCloud so parents or other invited family members see the same balances and transaction history.',
    },
    {
      question: 'Do you collect our data?',
      answer:
        'No. Munnies stores your data on device and in your iCloud account. There is no Munnies backend collecting family balances or transaction history.',
    },
    {
      question: 'What can I track in Munnies?',
      answer:
        'Allowance, chores, gifts, spending, and manual balance corrections. Each child gets their own account so activity stays organized.',
    },
  ],
  [
    {
      question: 'How many kids can I add?',
      answer:
        'As many as your family needs. Munnies is not limited to one or two child accounts.',
    },
    {
      question: 'Can I track spending too?',
      answer:
        'Yes. You can add money, record spending, and include notes so the full account history makes sense later.',
    },
    {
      question: 'Does it work on iPad?',
      answer:
        'Yes. Munnies is built for both iPhone and iPad, and iCloud keeps your data aligned between them.',
    },
  ],
  [
    {
      question: 'Do I need to create a separate Munnies login?',
      answer:
        'No. There is no separate Munnies account system. iCloud handles sync and sharing if you want those features.',
    },
    {
      question: 'What happens if I change devices?',
      answer:
        'Your data can sync through iCloud, so moving between an iPhone and iPad is straightforward as long as you use the same Apple account.',
    },
    {
      question: 'How do I get help?',
      answer:
        'Send a note to kent.fenwick@gmail.com and include your device model and iOS version if you are reporting a problem.',
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
            Frequently asked questions
          </h2>
          <p className="mt-2 text-lg text-gray-600">
            If you have anything else you want to ask,{' '}
            <a
              href="mailto:kent.fenwick@gmail.com"
              className="text-orange-600 underline"
            >
              reach out to us
            </a>
            .
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
