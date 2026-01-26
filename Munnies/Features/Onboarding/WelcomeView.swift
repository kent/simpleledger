import SwiftUI
import UIKit

struct WelcomeView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            iconName: "gift.fill",
            iconColor: .pink,
            title: "Kids Get Money",
            subtitle: "Birthdays, holidays, lemonade stands, tooth fairy..."
        ),
        OnboardingPage(
            iconName: "questionmark.circle.fill",
            iconColor: .orange,
            title: "How Much Do I Have?",
            subtitle: "You keep it safe. They keep asking."
        ),
        OnboardingPage(
            iconName: "dollarsign.circle.fill",
            iconColor: .green,
            title: "Meet Munnies",
            subtitle: "Track all your kids' money in one place."
        )
    ]

    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if !isLastPage {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(.secondary)
                    .padding()
                } else {
                    // Placeholder to maintain layout
                    Color.clear
                        .frame(height: 44)
                        .padding()
                }
            }

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(
                        iconName: page.iconName,
                        iconColor: page.iconColor,
                        title: page.title,
                        subtitle: page.subtitle
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Continue / Get Started button
            Button {
                if isLastPage {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            } label: {
                Text(isLastPage ? "Get Started" : "Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func completeOnboarding() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

private struct OnboardingPage {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
}

#Preview {
    WelcomeView()
}
