import Link from 'next/link'
import { Container } from '@/components/Container'
import { Button } from '@/components/Button'

export default function NotFound() {
  return (
    <Container className="flex min-h-screen flex-col items-center justify-center py-16 text-center">
      <p className="text-sm font-semibold text-orange-600">404</p>
      <h1 className="mt-4 text-3xl font-medium tracking-tight text-gray-900">
        Page not found
      </h1>
      <p className="mt-4 text-lg text-gray-600">
        Sorry, we couldn&apos;t find that page.
      </p>
      <div className="mt-8">
        <Button href="/" color="orange">
          Back to Munnies
        </Button>
      </div>
    </Container>
  )
}
