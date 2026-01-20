import { type Metadata } from 'next'

import { Container } from '@/components/Container'
import { Header } from '@/components/Header'
import { Footer } from '@/components/Footer'

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description: 'Privacy policy for Munnies, the family allowance tracking app.',
}

export default function PrivacyPage() {
  return (
    <>
      <Header />
      <main className="flex-auto py-20 sm:py-32">
        <Container>
          <div className="mx-auto max-w-2xl">
            <h1 className="text-3xl font-medium tracking-tight text-gray-900">
              Privacy Policy
            </h1>
            <div className="mt-8 prose prose-gray">
              <p className="text-gray-600">
                Last updated: January 2025
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Your Privacy Matters
              </h2>
              <p className="mt-4 text-gray-600">
                Munnies is designed with your privacy in mind. Your data stays in your
                iCloud account and is never shared with us or any third parties.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                What Data We Collect
              </h2>
              <p className="mt-4 text-gray-600">
                We don&apos;t collect any personal data. All your ledgers, transactions,
                and settings are stored locally on your device and in your personal
                iCloud account.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                iCloud Sync
              </h2>
              <p className="mt-4 text-gray-600">
                Munnies uses Apple&apos;s iCloud service to sync your data across your
                devices. This data is protected by Apple&apos;s privacy and security
                measures, and we have no access to it.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Sharing Features
              </h2>
              <p className="mt-4 text-gray-600">
                When you share a ledger with family members, the data is shared
                directly through iCloud sharing. We never see or store this shared data.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Contact Us
              </h2>
              <p className="mt-4 text-gray-600">
                If you have questions about our privacy practices, please contact us
                at{' '}
                <a
                  href="mailto:privacy@munnies.app"
                  className="text-emerald-600 hover:text-emerald-500"
                >
                  privacy@munnies.app
                </a>
                .
              </p>
            </div>
          </div>
        </Container>
      </main>
      <Footer />
    </>
  )
}
