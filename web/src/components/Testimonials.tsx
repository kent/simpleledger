import { Container } from '@/components/Container'

const testimonials = [
  {
    content:
      'My husband and I used to play "who gave Jake his allowance last week?" every Sunday. Not anymore!',
    author: 'Katie',
    role: 'Mom of 2 chaos agents',
    emoji: '🙌',
  },
  {
    content:
      'My 7-year-old asks to check her balance every day. She\'s learning to save and I barely had to do anything.',
    author: 'Lindsay',
    role: 'Mom of 3 future investors',
    emoji: '📈',
  },
  {
    content:
      'Grandma lives across the country. Now she can add birthday money and we all see it instantly. She loves it.',
    author: 'Christina',
    role: 'Mom of 1 spoiled grandchild',
    emoji: '👵',
  },
  {
    content:
      'Finally replaced our "money jar" that was really just a pile of IOUs I wrote on napkins.',
    author: 'Alex',
    role: 'Reformed napkin banker',
    emoji: '📝',
  },
  {
    content:
      'The confetti animation when my son gets $10 or more makes his whole day. It\'s the little things.',
    author: 'Kyle',
    role: 'Dad of a confetti enthusiast',
    emoji: '🎉',
  },
  {
    content:
      'Downloaded it on a whim. Set up 3 kids in under 2 minutes. Why didn\'t this exist years ago?',
    author: 'Aaron',
    role: 'Dad who wishes he had this sooner',
    emoji: '⏰',
  },
  {
    content:
      'No more mental math trying to remember if I owe Ella $5 or $15. It\'s all in the app.',
    author: 'John',
    role: 'Dad of 2 negotiators',
    emoji: '🧮',
  },
  {
    content:
      'We use it for chores too. Mow the lawn? Boom, $10 added. Kids are way more motivated now.',
    author: 'Meg',
    role: 'Mom who found the motivation hack',
    emoji: '🌱',
  },
  {
    content:
      'My wife and I are finally on the same page about the kids\' money. Game changer.',
    author: 'Dave',
    role: 'Dad who no longer gets "the look"',
    emoji: '👀',
  },
  {
    content:
      'Simple, beautiful, does exactly what it says. No bloat, no subscriptions, just works.',
    author: 'Marina',
    role: 'Mom who hates complicated apps',
    emoji: '✨',
  },
  {
    content:
      'My kids actually understand where their money goes now. That\'s worth more than any app.',
    author: 'Frank',
    role: 'Dad teaching financial literacy',
    emoji: '🎓',
  },
  {
    content:
      'I shared it with my sister and now we coordinate gifts. No more accidental doubles!',
    author: 'Ross',
    role: 'Uncle who nailed the birthday gift',
    emoji: '🎁',
  },
  {
    content:
      'The iCloud sync is magic. Updated on my phone, saw it on my iPad instantly.',
    author: 'Anne',
    role: 'Mom with too many Apple devices',
    emoji: '☁️',
  },
  {
    content:
      'Finally, an app that doesn\'t try to sell me a premium tier. Just pure usefulness.',
    author: 'Josh',
    role: 'Dad tired of upsells',
    emoji: '🙏',
  },
  {
    content:
      'My daughter counts her balance like a little banker now. It\'s adorable.',
    author: 'Heather',
    role: 'Mom of a future CFO',
    emoji: '💼',
  },
  {
    content:
      'Best free app I\'ve downloaded this year. And I download a LOT of apps.',
    author: 'Jack',
    role: 'Dad and app enthusiast',
    emoji: '📱',
  },
  {
    content:
      'We were using a spreadsheet. A SPREADSHEET. This is so much better.',
    author: 'Emma',
    role: 'Mom who escaped Excel hell',
    emoji: '📊',
  },
]

export function Testimonials() {
  return (
    <section
      id="testimonials"
      aria-label="What parents are saying"
      className="bg-emerald-50 py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-2xl sm:text-center">
          <h2 className="text-3xl font-medium tracking-tight text-gray-900">
            Real parents. Real relief.
          </h2>
          <p className="mt-2 text-lg text-gray-600">
            Join 10,000+ families who have simplified their allowance game.
          </p>
        </div>
        <ul
          role="list"
          className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-6 sm:mt-20 md:grid-cols-2 lg:max-w-none lg:grid-cols-3"
        >
          {testimonials.slice(0, 9).map((testimonial, index) => (
            <li
              key={index}
              className="rounded-2xl bg-white p-6 shadow-sm"
            >
              <div className="flex items-center gap-2">
                <span className="text-xl">{testimonial.emoji}</span>
                <div className="flex gap-0.5 text-emerald-500">
                  {[...Array(5)].map((_, i) => (
                    <svg
                      key={i}
                      className="h-3.5 w-3.5 fill-current"
                      viewBox="0 0 20 20"
                    >
                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                    </svg>
                  ))}
                </div>
              </div>
              <p className="mt-3 text-sm text-gray-700">&ldquo;{testimonial.content}&rdquo;</p>
              <div className="mt-4">
                <p className="text-sm font-semibold text-gray-900">{testimonial.author}</p>
                <p className="text-xs text-gray-500">{testimonial.role}</p>
              </div>
            </li>
          ))}
        </ul>
      </Container>
    </section>
  )
}
