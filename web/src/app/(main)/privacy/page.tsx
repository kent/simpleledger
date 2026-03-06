import { type Metadata } from 'next'
import { Container } from '@/components/Container'

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description: 'Munnies Privacy Policy - How Munnies handles family account data, iCloud sync, and support contact information.',
}

export default function PrivacyPage() {
  return (
    <Container className="py-16">
      <div className="mx-auto max-w-2xl">
        <h1 className="text-3xl font-medium tracking-tight text-gray-900">
          Privacy Policy
        </h1>
        <p className="mt-4 text-sm text-gray-500">Last updated: March 6, 2026</p>

        <div className="mt-8 space-y-8 text-gray-700">
          <section>
            <h2 className="text-xl font-semibold text-gray-900">Overview</h2>
            <p className="mt-4">
              Munnies is designed so your family account data stays under your
              control. We do not operate a Munnies backend that stores your
              child accounts, balances, or transaction history.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">What We Collect</h2>
            <p className="mt-4">
              We do not collect personal data, analytics events, advertising
              identifiers, crash reporting data, or family account content from
              the app. Munnies does not require you to create a Munnies account.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Data Storage</h2>
            <p className="mt-4">
              Your data is stored locally on your device and, if you enable
              sync, in your personal iCloud account using Apple&apos;s CloudKit
              framework. We do not store your data on Munnies-managed servers.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">iCloud Sync and Sharing</h2>
            <p className="mt-4">
              If you enable sync or share an account, your data is exchanged
              through Apple&apos;s iCloud and CloudKit services. Only people you
              explicitly invite through Apple&apos;s sharing flow can access shared
              account data, and you can stop sharing at any time.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Third Parties</h2>
            <p className="mt-4">
              Apple iCloud is the only third-party service used for optional
              sync and sharing features. We do not sell, rent, or transfer your
              data to advertisers, brokers, or analytics providers.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Children&apos;s Data</h2>
            <p className="mt-4">
              Munnies can be used to track balances and transactions for
              children, but we do not directly collect children&apos;s personal
              information. Any names, notes, or balances you enter stay on your
              device and in your iCloud account.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Your Choices</h2>
            <p className="mt-4">
              You can use Munnies locally without iCloud sync, disable iCloud
              for the app in your Apple settings, stop sharing accounts, or
              delete app data from your devices and iCloud account at any time.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-gray-900">Contact</h2>
            <p className="mt-4">
              If you have any questions about this privacy policy, please contact us at{' '}
              <a href="mailto:kent.fenwick@gmail.com" className="text-orange-600 underline">
                kent.fenwick@gmail.com
              </a>
              {' '}or visit our support page at{' '}
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
