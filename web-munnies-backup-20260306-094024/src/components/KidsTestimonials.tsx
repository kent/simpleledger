'use client'

import { motion } from 'framer-motion'
import { Container } from '@/components/Container'

const kidsTestimonials = [
  {
    content: 'I can finally see how much money I have without asking Mom 100 times!',
    author: 'Jack',
    age: 9,
    emoji: '🤑',
  },
  {
    content: 'The confetti when I get money is SO COOL. I saved up $50 for a video game!',
    author: 'Emma',
    age: 8,
    emoji: '🎮',
  },
  {
    content: 'I like that it has my favorite color and my unicorn emoji.',
    author: 'Pearl',
    age: 6,
    emoji: '🦄',
  },
  {
    content: 'Now I know exactly how many weeks of allowance until I can buy my skateboard.',
    author: 'Ruby',
    age: 10,
    emoji: '🛹',
  },
  {
    content: 'Dad can\'t say "I\'ll remember" and then forget anymore. It\'s in the app!',
    author: 'Frankie',
    age: 11,
    emoji: '😏',
  },
  {
    content: 'I check my balance every morning. I\'m going to be rich!',
    author: 'Leo',
    age: 7,
    emoji: '💰',
  },
  {
    content: 'Grandma adds birthday money from far away and I see it right away!',
    author: 'Sophia',
    age: 8,
    emoji: '🎂',
  },
  {
    content: 'I learned that if I save $2 every week, I can buy the big LEGO set in 10 weeks.',
    author: 'Aidan',
    age: 9,
    emoji: '🧱',
  },
]

export function KidsTestimonials() {
  return (
    <section
      aria-label="What kids are saying"
      className="py-20 sm:py-32"
    >
      <Container>
        <div className="mx-auto max-w-2xl sm:text-center">
          <h2 className="text-3xl font-medium tracking-tight text-gray-900">
            The kids love it too! 🧒
          </h2>
          <p className="mt-2 text-lg text-gray-600">
            Don&apos;t take our word for it. Here&apos;s what the real experts think.
          </p>
        </div>
        <div className="mx-auto mt-16 max-w-5xl sm:mt-20">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {kidsTestimonials.map((testimonial, index) => (
              <motion.div
                key={testimonial.author}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-gray-50 to-gray-100 p-5"
              >
                <div className="absolute -right-2 -top-2 text-6xl opacity-10 transition-transform group-hover:scale-110">
                  {testimonial.emoji}
                </div>
                <div className="relative">
                  <span className="text-3xl">{testimonial.emoji}</span>
                  <p className="mt-3 text-sm text-gray-700">
                    &ldquo;{testimonial.content}&rdquo;
                  </p>
                  <div className="mt-4">
                    <p className="text-sm font-semibold text-gray-900">
                      {testimonial.author}, age {testimonial.age}
                    </p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </Container>
    </section>
  )
}
