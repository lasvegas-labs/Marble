import Orb
import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isCollapsed: Bool

    private let onFinished: () -> Void
    private let orbConfiguration = OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        showShadow: false,
        speed: 45
    )

    init(onFinished: @escaping () -> Void, initiallyCollapsed: Bool = false) {
        self.onFinished = onFinished
        _isCollapsed = State(initialValue: initiallyCollapsed)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let fullDiameter = max(width, height) * 1.35
            let finalDiameter = min(width, height) * 0.25
            let finalScale = finalDiameter / fullDiameter
            let globalFrame = geometry.frame(in: .global)
            let topOffset = max(
                geometry.safeAreaInsets.top,
                globalFrame.minY
            )
            let localTopOffset = max(topOffset - globalFrame.minY, 0)
            let bottomOffset = geometry.safeAreaInsets.bottom
            let safeAreaHeight = max(height - localTopOffset - bottomOffset, 0)
            let safeAreaCenterY = localTopOffset + safeAreaHeight / 2
            let animationCenterY = safeAreaCenterY
            let orbCenterX = width / 2 - 8
            let textCenterX = width / 2

            ZStack(alignment: .topLeading) {
                Color(uiColor: .systemBackground)

                OrbView(configuration: orbConfiguration)
                    .frame(width: fullDiameter, height: fullDiameter)
                    .scaleEffect(isCollapsed ? finalScale : 1)
                    .position(x: orbCenterX, y: animationCenterY)
                    .accessibilityHidden(true)

                Text("MARBLE")
                    .font(.largeTitle.bold())
                    .tracking(5)
                    .foregroundStyle(isCollapsed ? Color.primary : Color.white)
                    .position(
                        x: textCenterX,
                        y: animationCenterY + (isCollapsed ? finalDiameter * 0.5 + 28 : 0)
                    )
                    .accessibilityLabel("Marble")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.8),
                value: isCollapsed
            )
        }
        .ignoresSafeArea()
        .task {
            await runAnimation()
        }
    }

    private func runAnimation() async {
        guard !reduceMotion else {
            isCollapsed = true
            onFinished()
            return
        }

        try? await Task.sleep(for: .milliseconds(600))
        guard !Task.isCancelled else { return }

        isCollapsed = true

        try? await Task.sleep(for: .milliseconds(1_050))
        guard !Task.isCancelled else { return }

        onFinished()
    }
}

#Preview("Step 1") {
    SplashView(onFinished: {})
}

#Preview("Step 2") {
    SplashView(onFinished: {}, initiallyCollapsed: true)
}
