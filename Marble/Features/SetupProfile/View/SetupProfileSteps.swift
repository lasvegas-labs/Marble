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

            Spacer(minLength: 64)

            GenderCard(
                title: "Male",
                emoji: "👨🏻",
                isSelected: viewModel.gender == .male
            ) {
                viewModel.gender = .male
            }

            GenderCard(
                title: "Female",
                emoji: "👩🏻",
                isSelected: viewModel.gender == .female
            ) {
                viewModel.gender = .female
            }

            Button(ProfileGender.preferNotToSay.title) {
                viewModel.gender = .preferNotToSay
            }
            .foregroundStyle(.primary)
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

            Spacer(minLength: 24)

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

            Spacer(minLength: 48)

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
            .foregroundStyle(.primary)
        }
    }
}

struct InterestsStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 12) {
            StepHeader(
                title: "What sparks your interest?",
                subtitle: "Your interests help us recommend meaningful alternatives when it's time to take a break."
            )

            Spacer(minLength: 32)

            ForEach(ProfileInterest.allCases) { interest in
                Button {
                    viewModel.toggleInterest(interest)
                } label: {
                    HStack(spacing: 14) {
                        Image(
                            systemName: viewModel.selectedInterests.contains(interest)
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .foregroundStyle(
                            viewModel.selectedInterests.contains(interest)
                                ? Color.teal
                                : Color.secondary
                        )

                        Image(systemName: interest.systemImage)
                            .frame(width: 26)

                        Text(interest.title)
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 8)
                }
                .accessibilityAddTraits(
                    viewModel.selectedInterests.contains(interest) ? .isSelected : []
                )

                Divider().padding(.leading, 72)
            }

            HStack(spacing: 14) {
                Image(systemName: "ellipsis.circle")
                    .frame(width: 26)
                TextField("Others (Type Here)", text: $viewModel.customInterest)
                    .textInputAutocapitalization(.sentences)
            }
            .padding(.vertical, 8)
        }
    }
}

struct ScreenTimePermissionStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            StepHeader(
                title: "Let's Connect Your Screen Time",
                subtitle: "Allow Screen Time access so we can measure your usage and provide timely reminders. Your personal content stays private."
            )

            Spacer(minLength: 40)

            Image(systemName: "hourglass.badge.shield")
                .font(.system(size: 72))
                .foregroundStyle(.teal)
                .accessibilityHidden(true)

            Text(permissionMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial, in: .rect(cornerRadius: 24))

            Spacer(minLength: 64)
        }
    }

    private var permissionMessage: String {
        switch viewModel.permissionStatus {
        case .notDetermined: "Tap Allow & Continue to show Apple's Screen Time permission request."
        case .denied: "Screen Time access was denied. You can enable it later in Settings."
        case .approved, .approvedWithDataAccess: "Screen Time access is ready."
        case .failed: "Screen Time is currently unavailable. You can continue without it."
        }
    }
}

struct DistractingAppsStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            StepHeader(
                title: "Choose Your Biggest Distraction",
                subtitle: "This helps us personalize reminders based on your app usage."
            )

            Spacer(minLength: 24)

            Button {
                viewModel.isActivityPickerPresented = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(Color.secondary.opacity(0.12), in: .rect(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Apps & Categories")
                            .font(.headline)
                        Text("\(viewModel.selectedDistractionCount) selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(18)
                .background(.regularMaterial, in: .rect(cornerRadius: 20))
            }
            .accessibilityHint("Opens Apple's app and category picker")

            selectedItems
        }
    }

    @ViewBuilder
    private var selectedItems: some View {
        if viewModel.selectedDistractionCount == 0 {
            ContentUnavailableView(
                "No Apps Selected",
                systemImage: "app.dashed",
                description: Text("Selection is optional and can be changed later.")
            )
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(viewModel.activitySelection.applicationTokens), id: \.self) { token in
                    Label(token)
                }
                ForEach(Array(viewModel.activitySelection.categoryTokens), id: \.self) { token in
                    Label(token)
                }
                ForEach(Array(viewModel.activitySelection.webDomainTokens), id: \.self) { token in
                    Label(token)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.secondary.opacity(0.08), in: .rect(cornerRadius: 20))
        }
    }
}

struct FocusWindowStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            StepHeader(
                title: "Create Your Focus Window",
                subtitle: "Choose when you want fewer distractions so we can remind you at the right moments."
            )

            VStack(alignment: .leading, spacing: 16) {
                Label("During this time", systemImage: "clock")
                    .font(.headline)

                HStack(spacing: 12) {
                    DatePicker(
                        "From",
                        selection: $viewModel.focusStartTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()

                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)

                    DatePicker(
                        "To",
                        selection: $viewModel.focusEndTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)

                if viewModel.crossesMidnight {
                    Text("Ends the following day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .background(.regularMaterial, in: .rect(cornerRadius: 22))

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
                                    ? .white
                                    : .primary
                            )
                            .background(
                                viewModel.selectedWeekdays.contains(weekday)
                                    ? Color.teal
                                    : Color.clear,
                                in: .circle
                            )
                            .overlay {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.3))
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
            .background(.regularMaterial, in: .rect(cornerRadius: 22))

            Text("You can add more focus windows in Settings later.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

struct OrbPersonaStepView: View {
    @ObservedObject var viewModel: SetupProfileViewModel

    var body: some View {
        VStack(spacing: 22) {
            StepHeader(
                title: "Choose Your Companion",
                subtitle: "Everyone has a different way of staying motivated."
            )

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(20)
                .frame(maxWidth: 280)
                .background(speechColor.opacity(0.45), in: .rect(cornerRadius: 16))

            OrbView(configuration: configuration)
                .frame(width: 210, height: 210)
                .accessibilityHidden(true)

            Spacer(minLength: 20)

            Slider(
                value: Binding(
                    get: { viewModel.orbPersona.index },
                    set: { viewModel.orbPersona = OrbPersona(index: $0) }
                ),
                in: 0...2,
                step: 1
            )
            .tint(speechColor)
            .accessibilityLabel("ORB persona")
            .accessibilityValue(viewModel.orbPersona.title)

            HStack {
                ForEach(OrbPersona.allCases) { persona in
                    Text(persona.title)
                        .font(.caption.weight(
                            persona == viewModel.orbPersona ? .bold : .regular
                        ))
                        .foregroundStyle(
                            persona == viewModel.orbPersona ? .primary : .secondary
                        )
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .sensoryFeedback(.selection, trigger: viewModel.orbPersona)
    }

    private var message: String {
        switch viewModel.orbPersona {
        case .gentle: "Looks like you've been scrolling for a while. Ready for a short break?"
        case .passiveAggressive: "Still scrolling? Your focus window was a lovely idea."
        case .blunt: "You've been scrolling for a while. It's time for a break."
        }
    }

    private var speechColor: Color {
        switch viewModel.orbPersona {
        case .gentle: .mint
        case .passiveAggressive: .yellow
        case .blunt: .orange
        }
    }

    private var configuration: OrbConfiguration {
        switch viewModel.orbPersona {
        case .gentle:
            OrbConfiguration(
                backgroundColors: [.cyan, .mint, .teal],
                glowColor: .cyan,
                showShadow: false,
                speed: 40
            )
        case .passiveAggressive:
            OrbConfiguration(
                backgroundColors: [.yellow, .orange, .pink],
                glowColor: .yellow,
                showShadow: false,
                speed: 60
            )
        case .blunt:
            OrbConfiguration(
                backgroundColors: [.red, .orange, .yellow],
                glowColor: .orange,
                showShadow: false,
                speed: 80
            )
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

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.teal : Color.secondary.opacity(0.35))
            }
            .foregroundStyle(.primary)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? Color.teal.opacity(0.08) : Color.clear,
                in: .rect(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.teal : Color.secondary.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct GenderCard: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(emoji).font(.largeTitle)
                Text(title).font(.title3.bold())
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(
                isSelected ? Color.teal.opacity(0.08) : Color.clear,
                in: .rect(cornerRadius: 24)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? Color.teal : Color.secondary.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
