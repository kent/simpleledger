import SwiftUI

struct OnboardingPageView: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon in colored circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(iconColor)
            }

            // Title
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            // Subtitle
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingPageView(
        iconName: "gift.fill",
        iconColor: .pink,
        title: "Kids Get Money",
        subtitle: "Birthdays, holidays, lemonade stands, tooth fairy..."
    )
}
