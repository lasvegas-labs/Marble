import FamilyControls
import Orb
import SwiftUI

struct GenderStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            StepHeader(
                title: "Getting To Know You",
                subtitle: "Select your gender to help us personalize your experience."
            )

            Spacer(minLength: 28)

            GenderCard(
                title: "Male",
                imageName: "male_avatar",
                isSelected: viewModel.gender == .male
            ) {
                viewModel.gender = .male
            }

            GenderCard(
                title: "Female",
                imageName: "female_avatar",
                isSelected: viewModel.gender == .female
            ) {
                viewModel.gender = .female
            }

            Button(ProfileGender.preferNotToSay.title) {
                viewModel.gender = .preferNotToSay
            }
            .font(.system(.body, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.top, 12)
            .accessibilityAddTraits(
                viewModel.gender == .preferNotToSay ? .isSelected : []
            )
        }
    }
}

struct AgeRangeStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            StepHeader(
                title: "Getting To Know You",
                subtitle: "Choose your age range to help us personalize your experience."
            )

            Spacer(minLength: 28)

            ForEach(ProfileAgeRange.allCases) { ageRange in
                SelectionRow(
                    title: ageRange.title,
                    isSelected: viewModel.ageRange == ageRange
                ) {
                    viewModel.ageRange = ageRange
                }
            }
        }
    }
}

struct BackgroundStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel
    let onPreferNotToSay: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            StepHeader(
                title: "Getting To Know You",
                subtitle: "We'll personalize your experience based on your current role."
            )

            Spacer(minLength: 28)

            ForEach([ProfileBackground.student, .worker, .other]) { background in
                SelectionRow(
                    title: background.title,
                    isSelected: viewModel.background == background
                ) {
                    viewModel.background = background
                }
            }

            if viewModel.background == .other {
                TextField("Tell us about your background", text: $viewModel.customBackground)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
            }

            Button(ProfileBackground.preferNotToSay.title) {
                viewModel.background = .preferNotToSay
                onPreferNotToSay()
            }
            .font(.system(.body, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.top, 12)
        }
    }
}

struct InterestsStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            StepHeader(
                title: "What sparks your interest?",
                subtitle: "Your interests help us recommend meaningful alternatives when it's time to take a break."
            )

            Spacer(minLength: 28)

            ForEach(ProfileInterest.allCases) { interest in
                InterestCard(
                    interest: interest,
                    isSelected: viewModel.selectedInterests.contains(interest)
                ) {
                    viewModel.toggleInterest(interest)
                }
            }

            OtherInterestCard(text: $viewModel.customInterest)
        }
    }
}

struct ScreenTimePermissionStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                title: "Let's connect Marble to Screen Time settings. Securely.",
                subtitle: "Your information is protected by Apple and will stay 100% on your phone."
            )

            Spacer()

            ZStack(alignment: .bottomLeading) {
                // Outer Outline Container (Gradiant Line Frame)
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.82, blue: 0.58),
                                Color(red: 0.0, green: 0.72, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 320, height: 230)
                    .overlay(
                        // Inner Mock System Permission Card (Light Glassmorphism with Margin)
                        VStack(spacing: 12) {
                            Text("\"Marble\" Would Like to Access Screen Time")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Providing \"Marble\" access to Screen Time may allow it to see your activity data, restrict content, and limit the usage of apps and websites.")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(1.5)
                                .padding(.horizontal, 8)
                            
                            HStack(spacing: 12) {
                                Button {
                                    Task {
                                        _ = await viewModel.continueCurrentStep()
                                    }
                                } label: {
                                    Text("Continue")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .frame(width: 105, height: 38)
                                        .background(Color.black.opacity(0.06), in: .capsule)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    Task {
                                        _ = await viewModel.continueCurrentStep()
                                    }
                                } label: {
                                    Text("Don't Allow")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 105, height: 38)
                                        .background(Color.blue, in: .capsule)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .frame(width: 300, height: 210)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.18))
                        )
                        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                    )
                
                // Guide arrow pointing to Continue button area
                VStack(spacing: 4) {
                    CurvedArrow()
                    Text("Tap Continue")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.58))
                }
                .offset(x: 20, y: 72)
            }
            .offset(y: 40)
            .padding(.bottom, 60)

            Spacer()
        }
    }
}

struct DistractingAppsStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            StepHeader(
                title: "Choose Your Biggest Distraction",
                subtitle: "This helps us personalize reminders based on your app usage."
            )

            Spacer(minLength: 8)

            // Embedded Native FamilyActivityPicker (direct pick list)
            FamilyActivityPicker(
                selection: $viewModel.activitySelection
            )
            .frame(height: 450)
            .cornerRadius(24)

            // App selection count footer
            Text("\(viewModel.selectedDistractionCount) Apps Selected")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(viewModel.selectedDistractionCount > 0 ? Color(red: 0.0, green: 0.82, blue: 0.58) : .secondary)
                .padding(.top, 4)
        }
    }
}

struct FocusWindowStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)

    var body: some View {
        VStack(spacing: 20) {
            StepHeader(
                title: "Create Your Focus\nWindow",
                subtitle: "Choose when you want fewer distractions so we can remind you at the right moments."
            )

            Spacer(minLength: 28)

            VStack(alignment: .leading, spacing: 16) {
                Label("During this time", systemImage: "clock")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("From")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TimeFieldBox(time: $viewModel.focusStartTime)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("To")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TimeFieldBox(time: $viewModel.focusEndTime)
                    }

                    Spacer(minLength: 0)
                }

                if viewModel.crossesMidnight {
                    Text("Ends the following day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .focusCard()

            VStack(alignment: .leading, spacing: 14) {
                Label("On these days", systemImage: "calendar")
                    .font(.headline)

                HStack(spacing: 7) {
                    ForEach(FocusWeekday.allCases) { weekday in
                        VStack(spacing: 6) {
                            Button(weekday.shortTitle) {
                                viewModel.toggleWeekday(weekday)
                            }
                            .font(.headline)
                            .frame(width: 38, height: 38)
                            .foregroundStyle(
                                viewModel.selectedWeekdays.contains(weekday)
                                    ? mintGreen
                                    : .primary
                            )
                            .background(
                                viewModel.selectedWeekdays.contains(weekday)
                                    ? mintGreen.opacity(0.15)
                                    : Color.clear,
                                in: .circle
                            )
                            .overlay {
                                Circle()
                                    .stroke(
                                        viewModel.selectedWeekdays.contains(weekday)
                                            ? mintGreen
                                            : Color.secondary.opacity(0.3),
                                        lineWidth: viewModel.selectedWeekdays.contains(weekday) ? 1.5 : 1
                                    )
                            }
                            .accessibilityLabel(weekday.title)
                            .accessibilityAddTraits(
                                viewModel.selectedWeekdays.contains(weekday) ? .isSelected : []
                            )

                            Text(weekday.title)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(20)
            .focusCard()

            Text("You can add more focus windows in Settings later.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private extension View {
    func focusCard() -> some View {
        self
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
    }
}

private struct TimeFieldBox: View {
    @Binding var time: Date
    @State private var isPickerPresented = false

    private let step = 15

    var body: some View {
        HStack(spacing: 8) {
            Button {
                isPickerPresented = true
            } label: {
                Text(time, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.primary)
                    .environment(\.locale, Locale(identifier: "en_US_POSIX"))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isPickerPresented) {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(width: 160, height: 160)
                .padding(8)
                .presentationCompactAdaptation(.popover)
            }

            VStack(spacing: 3) {
                Button {
                    nudge(by: step)
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 9, weight: .bold))
                }
                Button {
                    nudge(by: -step)
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.08), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(time, format: .dateTime.hour().minute()))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: nudge(by: step)
            case .decrement: nudge(by: -step)
            default: break
            }
        }
    }

    private func nudge(by minutes: Int) {
        time = Calendar.current.date(byAdding: .minute, value: minutes, to: time) ?? time
    }
}

struct OrbPersonaStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel
    @State private var sliderValue: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            StepHeader(
                title: "Choose Your Companion",
                subtitle: "Everyone has a different way of staying motivated."
            )

            Spacer(minLength: 16)

            Text(message)
                .font(.system(.body, design: .rounded))
                .fontWeight(.regular)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 24)
                .frame(width: 290, height: 115)
                .background(
                    SpeechBubble(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                )
                .background(
                    SpeechBubble(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .background(
                    SpeechBubble(cornerRadius: 20)
                        .fill(Color.white.opacity(0.25))
                )
                .background(.thinMaterial, in: SpeechBubble(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)

            Spacer(minLength: 16)

            DynamicOrbView(
                personality: viewModel.orbPersonality,
                sliderValue: 0.0
            )
            .frame(width: 210, height: 210)
            .accessibilityHidden(true)

            Spacer(minLength: 24)

            Slider(
                value: $sliderValue,
                in: 0...2,
                onEditingChanged: { isEditing in
                    if !isEditing {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            sliderValue = sliderValue.rounded()
                        }
                    }
                }
            )
            .background(
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .position(x: 4, y: geo.size.height / 2)
                        
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .position(x: geo.size.width - 4, y: geo.size.height / 2)
                    }
                }
            )
            .tint(speechColor)
            .accessibilityLabel("ORB companion")
            .accessibilityValue(viewModel.orbPersonality.title)
            .onChange(of: sliderValue) { _, newValue in
                let closestIndex = Int(newValue.rounded())
                let targetPersonality = OrbPersonality.allCases[closestIndex]
                if viewModel.orbPersonality != targetPersonality {
                    withAnimation(.smooth(duration: 0.4)) {
                        viewModel.orbPersonality = targetPersonality
                    }
                }
            }

            Spacer(minLength: 12)

            HStack {
                ForEach(OrbPersonality.allCases) { personality in
                    Text(personality.title)
                        .font(.system(size: 11, weight: personality == viewModel.orbPersonality ? .bold : .regular, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(
                            personality == viewModel.orbPersonality ? .primary : .secondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 18)
                }
            }
        }
        .frame(height: 570)
        .sensoryFeedback(.selection, trigger: viewModel.orbPersonality)
        .onAppear {
            sliderValue = viewModel.orbPersonality.index
        }
    }

    private var message: String {
        switch viewModel.orbPersonality {
        case .gentle: "Looks like you've been scrolling for a while. Ready for a short break?"
        case .passive: "Still scrolling? Your focus window was a lovely idea."
        case .aggressive: "You've been scrolling for a while. It's time for a break."
        }
    }

    private var speechColor: Color {
        switch viewModel.orbPersonality {
        case .gentle: .mint
        case .passive: .yellow
        case .aggressive: .orange
        }
    }

    private var gradientColors: [Color] {
        switch viewModel.orbPersonality {
        case .gentle:
            return [Color(red: 0.0, green: 0.82, blue: 0.58).opacity(0.22), Color.white.opacity(0.05)]
        case .passive:
            return [Color(red: 1.0, green: 0.72, blue: 0.3).opacity(0.25), Color.white.opacity(0.05)]
        case .aggressive:
            return [Color(red: 1.0, green: 0.35, blue: 0.45).opacity(0.22), Color.white.opacity(0.05)]
        }
    }

    private var borderColor: Color {
        switch viewModel.orbPersonality {
        case .gentle:
            return Color.mint.opacity(0.35)
        case .passive:
            return Color.orange.opacity(0.35)
        case .aggressive:
            return Color.red.opacity(0.35)
        }
    }
}

private struct StepHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 340)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? mintGreen : Color.secondary.opacity(0.35))
            }
            .foregroundStyle(.primary)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? mintGreen.opacity(0.06) : Color(uiColor: .systemBackground),
                in: .rect(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? mintGreen : Color.secondary.opacity(0.2),
                        lineWidth: isSelected ? 1.5 : 1.0
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct GenderCard: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)

    var body: some View {
        VStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 115)
        .background(
            isSelected ? mintGreen.opacity(0.06) : Color(uiColor: .systemBackground),
            in: .rect(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isSelected ? mintGreen : Color.secondary.opacity(0.2),
                    lineWidth: isSelected ? 1.5 : 1.0
                )
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct InterestCard: View {
    let interest: ProfileInterest
    let isSelected: Bool
    let action: () -> Void

    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: interest.systemImage)
                    .font(.system(size: 20))
                    .frame(width: 28)
                    .foregroundStyle(isSelected ? mintGreen : .primary)

                Text(interest.title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? mintGreen : Color.secondary.opacity(0.35))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? mintGreen.opacity(0.06) : Color(uiColor: .systemBackground),
                in: .rect(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? mintGreen : Color.secondary.opacity(0.2),
                        lineWidth: isSelected ? 1.5 : 1.0
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct OtherInterestCard: View {
    @Binding var text: String
    
    private let mintGreen = Color(red: 0.0, green: 0.82, blue: 0.58)
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "square.dashed")
                .font(.system(size: 20))
                .frame(width: 28)
                .foregroundStyle(text.isEmpty ? Color.secondary : mintGreen)

            TextField("Others (Type Here)", text: $text)
                .font(.headline)
                .textInputAutocapitalization(.sentences)
            
            Spacer()
            
            Image(systemName: text.isEmpty ? "circle" : "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(text.isEmpty ? Color.secondary.opacity(0.35) : mintGreen)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            text.isEmpty ? Color(uiColor: .systemBackground) : mintGreen.opacity(0.06),
            in: .rect(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    text.isEmpty ? Color.secondary.opacity(0.2) : mintGreen,
                    lineWidth: text.isEmpty ? 1.0 : 1.5
                )
        }
    }
}

struct SpeechBubble: Shape {
    var cornerRadius: CGFloat = 20
    var arrowSize: CGSize = CGSize(width: 18, height: 10)
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - arrowSize.height
        )
        
        // Draw the rounded bubble rectangle
        path.addRoundedRect(in: bubbleRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        // Draw the curved arrow pointing down in the center
        let arrowX = rect.midX
        let arrowY = rect.maxY
        let arrowBottom = rect.height - arrowSize.height
        
        path.move(to: CGPoint(x: arrowX - arrowSize.width / 2, y: arrowBottom))
        
        // Left curve to tip
        path.addQuadCurve(
            to: CGPoint(x: arrowX, y: arrowY),
            control: CGPoint(x: arrowX - arrowSize.width * 0.15, y: arrowBottom + arrowSize.height * 0.45)
        )
        
        // Right curve from tip
        path.addQuadCurve(
            to: CGPoint(x: arrowX + arrowSize.width / 2, y: arrowBottom),
            control: CGPoint(x: arrowX + arrowSize.width * 0.15, y: arrowBottom + arrowSize.height * 0.45)
        )
        
        return path
    }
}

struct CurvedArrow: View {
    var body: some View {
        ZStack {
            CurvedArrowPath()
                .stroke(
                    Color(red: 0.0, green: 0.82, blue: 0.58),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
            
            // Arrowhead at the tip pointing up-left
            Image(systemName: "arrowtriangle.up.fill")
                .font(.system(size: 10))
                .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.58))
                .rotationEffect(.degrees(-60))
                .position(x: 18, y: 14)
        }
        .frame(width: 80, height: 60)
    }
}

struct CurvedArrowPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Starts at bottom right, curves up-left
        path.move(to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 15, y: rect.minY + 12),
            control: CGPoint(x: rect.maxX - 20, y: rect.minY + 35)
        )
        return path
    }
}
