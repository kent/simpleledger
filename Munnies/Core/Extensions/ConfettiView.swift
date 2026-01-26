import SwiftUI
import Darwin

struct ConfettiView: View {
    @Binding var isShowing: Bool

    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { index in
                    ConfettiPiece(
                        color: colors[index % colors.count],
                        size: CGFloat.random(in: 8...14),
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: -20
                        ),
                        screenHeight: geometry.size.height
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .opacity(isShowing ? 1 : 0)
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isShowing = false
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let screenHeight: CGFloat

    @State private var offset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var horizontalOffset: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 1.5)
            .cornerRadius(2)
            .rotationEffect(.degrees(rotation))
            .position(x: position.x + horizontalOffset, y: position.y + offset)
            .onAppear {
                let duration = Double.random(in: 1.5...2.5)
                let delay = Double.random(in: 0...0.3)

                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    offset = screenHeight + 100
                    rotation = Double.random(in: 360...720)
                    horizontalOffset = CGFloat.random(in: -50...50)
                }
            }
    }
}

// MARK: - Money Burst Effect (simpler, for inline use)

struct MoneyBurstView: View {
    @Binding var isShowing: Bool
    let isPositive: Bool

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(isPositive ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .offset(burstOffset(for: index))
                    .opacity(isShowing ? 0 : 1)
                    .scaleEffect(isShowing ? 2 : 0.5)
            }
        }
        .animation(.easeOut(duration: 0.4), value: isShowing)
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowing = false
                }
            }
        }
    }

    private func burstOffset(for index: Int) -> CGSize {
        let angle = Double(index) * (360.0 / 8.0)
        let radians = angle * Double.pi / 180.0
        let distance: Double = isShowing ? 40 : 0
        return CGSize(
            width: Darwin.cos(radians) * distance,
            height: Darwin.sin(radians) * distance
        )
    }
}

// MARK: - View Extension for Confetti

extension View {
    func confetti(isShowing: Binding<Bool>) -> some View {
        ZStack {
            self
            ConfettiView(isShowing: isShowing)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showConfetti = false

        var body: some View {
            VStack {
                Button("Celebrate!") {
                    showConfetti = true
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .confetti(isShowing: $showConfetti)
        }
    }

    return PreviewWrapper()
}
