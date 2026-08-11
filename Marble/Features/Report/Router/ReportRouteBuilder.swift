import SwiftUI

struct ReportRouteBuilder {
    @ViewBuilder
    static func build(_ route: ReportRoute) -> some View {
        switch route {
        case .main:
            ReportView(viewModel: ReportViewModel())
        }
    }
}
