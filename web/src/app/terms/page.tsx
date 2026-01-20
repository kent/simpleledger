import { type Metadata } from 'next'

import { Container } from '@/components/Container'
import { Header } from '@/components/Header'
import { Footer } from '@/components/Footer'

export const metadata: Metadata = {
  title: 'Terms of Service',
  description: 'Terms of service for Munnies, the family allowance tracking app.',
}

export default function TermsPage() {
  return (
    <>
      <Header />
      <main className="flex-auto py-20 sm:py-32">
        <Container>
          <div className="mx-auto max-w-2xl">
            <h1 className="text-3xl font-medium tracking-tight text-gray-900">
              Terms of Service
            </h1>
            <div className="mt-8 prose prose-gray">
              <p className="text-gray-600">
                Last updated: January 2025
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Acceptance of Terms
              </h2>
              <p className="mt-4 text-gray-600">
                By downloading or using Munnies, you agree to these terms of service.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Use of the App
              </h2>
              <p className="mt-4 text-gray-600">
                Munnies is provided as a tool to help families track allowances and
                spending. The app is intended for personal, non-commercial use only.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Your Data
              </h2>
              <p className="mt-4 text-gray-600">
                You are responsible for the data you enter into Munnies. We recommend
                keeping iCloud backup enabled to prevent data loss.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                No Financial Advice
              </h2>
              <p className="mt-4 text-gray-600">
                Munnies is a tracking tool only. It does not provide financial advice
                or handle real money transactions.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Limitation of Liability
              </h2>
              <p className="mt-4 text-gray-600">
                Munnies is provided &quot;as is&quot; without warranties of any kind. We are
                not liable for any damages arising from your use of the app.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Changes to Terms
              </h2>
              <p className="mt-4 text-gray-600">
                We may update these terms from time to time. Continued use of the app
                after changes constitutes acceptance of the new terms.
              </p>

              <h2 className="mt-8 text-xl font-semibold text-gray-900">
                Contact Us
              </h2>
              <p className="mt-4 text-gray-600">
                If you have questions about these terms, please contact us at{' '}
                <a
                  href="mailto:support@munnies.app"
                  className="text-emerald-600 hover:text-emerald-500"
                >
                  support@munnies.app
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
