import SwiftUI
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
    static let topStats = Self("Top Stats")
    static let chartAndUsage = Self("Chart And Usage")
}

struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var screenTimeManager = ScreenTimeManager.shared
    
    init(viewModel: ReportViewModel = ReportViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if screenTimeManager.hasAuthorization {
                if screenTimeManager.selectionToDiscourage.applicationTokens.isEmpty && screenTimeManager.selectionToDiscourage.categoryTokens.isEmpty {
                    noAppsSelectedState
                } else {
                    reportContent
                }
            } else {
                emptyState
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            screenTimeManager.checkAuthorizationStatus()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.18, green: 0.83, blue: 0.75))
            
            Text("Screen Time Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Marble needs access to Screen Time to generate your report.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                screenTimeManager.requestAuthorization()
            }) {
                Text("Grant Access")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.18, green: 0.83, blue: 0.75))
                    .cornerRadius(16)
            }
        }
        .padding(32)
    }
    
    private var noAppsSelectedState: some View {
        VStack(spacing: 24) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.18, green: 0.83, blue: 0.75))
            
            Text("No Apps Selected")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please pick the apps you want to track from the Settings page.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(32)
    }
    
    private var reportContent: some View {
        List {
            // Header
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Report")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("See the real cost of your screen time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            
            // Top Stats (Card + Suggestions)
            Section {
                DeviceActivityReport(.topStats, filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: viewModel.selectedStartDate, end: viewModel.selectedStartDate.addingTimeInterval(7*86400)))))
                    .frame(height: 380)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            
            // Date Picker
            Section {
                HStack {
                    Text(viewModel.dateRangeText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    ZStack(alignment: .trailing) {
                        DatePicker(
                            "",
                            selection: $viewModel.selectedStartDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .colorMultiply(.clear)
                        
                        Image(systemName: "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.18, green: 0.83, blue: 0.75))
                            .allowsHitTesting(false)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            
            // Chart + App Usage
            Section {
                DeviceActivityReport(.chartAndUsage, filter: DeviceActivityFilter(segment: .daily(during: DateInterval(start: viewModel.selectedStartDate, end: viewModel.selectedStartDate.addingTimeInterval(7*86400)))))
                    .frame(height: 680)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
}
