import { type Metadata } from 'next'
import { Container } from '@/components/Container'

export const metadata: Metadata = {
  title: 'Terms of Service',
  description: 'Munnies Terms of Service - Terms for using the Munnies iPhone and iPad app and website.',
}

export default function TermsPage() {
  return (
    <Container className="py-16">
      <div className="mx-auto max-w-2xl">
        <h1 className="text-3xl font-medium tracking-tight text-gray-900">
          Terms of Service
        </h1>
        <p className="mt-4 text-sm text-gray-500">Last updated: March 6, 2026</p>

        <div className="mt-8 space-y-8 text-gray-700">
          <section>
            <h2 className="text-xl font-semibold text-gray-900">Acceptance of Terms</h2>
            <p className="mt-4">
              By downloading or using Munnies, you agree to be bound by these
              Terms of Service.
              If you do not agree to these terms, please do not use the app.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">License and Purchase</h2>
            <p className="mt-4">
              Munnies grants you a personal, non-transferable, non-exclusive
              license to use the app on your Apple devices. This license does
              not include the right to modify, distribute, or create derivative
              works based on the app. Munnies is sold as a one-time paid app.
              Any purchase processing, billing, refunds, or taxes are handled
              through Apple under the App Store terms that apply to your region.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">User Content</h2>
            <p className="mt-4">
              You retain ownership of the data you create within Munnies,
              including account names, balances, notes, and transaction history.
              You are responsible for the accuracy of the information you enter.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">iCloud and Sharing</h2>
            <p className="mt-4">
              If you choose to enable iCloud sync or share an account with
              other people, those features rely on Apple services and your Apple
              account. You are responsible for managing your Apple ID, device
              security, and the people you invite to shared accounts.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Prohibited Uses</h2>
            <p className="mt-4">You agree not to:</p>
            <ul className="mt-2 list-disc pl-6 space-y-2">
              <li>Use the app for any illegal purpose</li>
              <li>Attempt to reverse engineer or decompile the app</li>
              <li>Use Munnies to misrepresent financial records or obligations</li>
              <li>Use the app in any way that could damage or impair its functionality</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Disclaimer</h2>
            <p className="mt-4">
              Munnies is provided &quot;as is&quot; without warranties of any kind. We
              do not guarantee that the app will be error-free or uninterrupted.
              Munnies is a tracking tool for family use and does not provide
              financial, accounting, tax, or legal advice, and it does not
              handle real money transfers.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Limitation of Liability</h2>
            <p className="mt-4">
              To the maximum extent permitted by law, Munnies shall not be liable
              for any indirect, incidental, special, or consequential damages
              arising from your use of the app.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Changes to Terms</h2>
            <p className="mt-4">
              We reserve the right to modify these terms at any time. Changes will be effective
              immediately upon posting. Your continued use of the app after changes constitutes
              acceptance of the modified terms.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Contact</h2>
            <p className="mt-4">
              If you have any questions about these terms, please contact us at{' '}
              <a href="mailto:kent.fenwick@gmail.com" className="text-orange-600 underline">
                kent.fenwick@gmail.com
              </a>
              {' '}or visit{' '}
              <a href="https://munnies.com/support" className="text-orange-600 underline">
                munnies.com/support
              </a>.
            </p>
          </section>
        </div>
      </div>
    </Container>
  )
}
