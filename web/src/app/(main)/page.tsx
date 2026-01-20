import { CallToAction } from '@/components/CallToAction'
import { Faqs } from '@/components/Faqs'
import { Features } from '@/components/Features'
import { Hero } from '@/components/Hero'
import { HowItWorks } from '@/components/HowItWorks'
import { KidsTestimonials } from '@/components/KidsTestimonials'
import { Testimonials } from '@/components/Testimonials'

export default function Home() {
  return (
    <>
      <Hero />
      <Features />
      <HowItWorks />
      <Testimonials />
      <KidsTestimonials />
      <CallToAction />
      <Faqs />
    </>
  )
}
