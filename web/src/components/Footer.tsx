import Link from 'next/link'

import { Container } from '@/components/Container'
import { Logomark } from '@/components/Logo'
import { NavLinks } from '@/components/NavLinks'

export function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-gray-50">
      <Container>
        <div className="flex flex-col items-start justify-between gap-y-12 pt-16 pb-6 lg:flex-row lg:items-center lg:py-16">
          <div>
            <div className="flex items-center text-gray-900">
              <Logomark className="h-10 w-10 flex-none" />
              <div className="ml-4">
                <p className="text-base font-semibold">Munnies</p>
                <p className="mt-1 text-sm text-gray-600">
                  Making parenting one IOU easier 💚
                </p>
              </div>
            </div>
            <nav className="mt-11 flex gap-8">
              <NavLinks />
            </nav>
          </div>
          <div className="rounded-2xl bg-white p-6 shadow-sm lg:w-72">
            <p className="text-base font-semibold text-gray-900">
              <Link href="https://apps.apple.com/app/munnies" className="hover:text-emerald-600">
                📱 Get the app
              </Link>
            </p>
            <p className="mt-2 text-sm text-gray-600">
              Free on the App Store. No account needed. Start tracking in 30 seconds!
            </p>
          </div>
        </div>
        <div className="flex flex-col items-center border-t border-gray-200 pt-8 pb-12 md:flex-row-reverse md:justify-between md:pt-6">
          <div className="flex gap-6 text-sm text-gray-500">
            <Link href="/privacy" className="hover:text-gray-900">
              Privacy
            </Link>
            <Link href="/terms" className="hover:text-gray-900">
              Terms
            </Link>
            <a href="mailto:support@munnies.app" className="hover:text-gray-900">
              Contact
            </a>
          </div>
          <p className="mt-6 text-sm text-gray-500 md:mt-0">
            Made with 💚 by parents, for parents. &copy; {new Date().getFullYear()} Munnies
          </p>
        </div>
      </Container>
    </footer>
  )
}
