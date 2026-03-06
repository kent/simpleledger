import { type Metadata } from 'next'

import { Container } from '@/components/Container'
import { appStoreUrl, siteUrl } from '@/lib/site'

export const metadata: Metadata = {
  title: 'Support',
  description: 'Munnies support information, contact details, and links to the App Store, privacy policy, and terms.',
}

export default function SupportPage() {
  return (
    <Container className="py-16">
      <div className="mx-auto max-w-2xl">
        <h1 className="text-3xl font-medium tracking-tight text-gray-900">
          Support
        </h1>
        <p className="mt-4 text-gray-700">
          Munnies is a private family money tracker for iPhone and iPad. If you
          need help with setup, iCloud sync, account sharing, or App Store
          access, use the contact details below.
        </p>

        <div className="mt-10 space-y-8 text-gray-700">
          <section>
            <h2 className="text-xl font-semibold text-gray-900">Contact</h2>
            <p className="mt-4">
              Email:{' '}
              <a href="mailto:kent.fenwick@gmail.com" className="text-orange-600 underline">
                kent.fenwick@gmail.com
              </a>
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Common Topics</h2>
            <ul className="mt-4 list-disc space-y-2 pl-6">
              <li>Turning iCloud sync on or off for Munnies</li>
              <li>Accepting or removing shared account invitations</li>
              <li>Restoring access after reinstalling the app</li>
              <li>Questions about the one-time App Store purchase</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Legal</h2>
            <p className="mt-4">
              Privacy Policy:{' '}
              <a href={`${siteUrl}/privacy`} className="text-orange-600 underline">
                munnies.com/privacy
              </a>
            </p>
            <p className="mt-2">
              Terms of Service:{' '}
              <a href={`${siteUrl}/terms`} className="text-orange-600 underline">
                munnies.com/terms
              </a>
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">App Store</h2>
            <p className="mt-4">
              Download page:{' '}
              <a href={appStoreUrl} className="text-orange-600 underline">
                {appStoreUrl}
              </a>
            </p>
          </section>
        </div>
      </div>
    </Container>
  )
}
