import SwiftUI
import UIKit

struct ProfileView: View {
    @Bindable var model: AppModel
    @State private var exportURL: URL?
    @State private var showingExportSheet = false
    @State private var exportError: String?

    var body: some View {
        ScreenScroll(title: nil) {
            VStack(spacing: 10) {
                Text(model.avatarInitial)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(NFTheme.gradient)
                    .clipShape(Circle())
                Text(model.displayName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(NFTheme.text)
                Text("Member since Jan 2026")
                    .font(.system(size: 13))
                    .foregroundStyle(NFTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 10) {
                MiniProfileStat(value: "5", label: "Streak")
                MiniProfileStat(value: "21", label: "Best streak")
                MiniProfileStat(value: "42", label: "Total fasts")
            }

            VStack(spacing: 0) {
                SettingsRow(title: "Privacy", detail: "On this iPhone", showsChevron: false) {}
                SettingsRow(title: "Cloud Backup", detail: "Backlog", showsChevron: false) {}
                SettingsRow(title: "Fasting Plan", detail: model.selectedPlan.rawValue) {
                    model.showPlanSelection(fromProfile: true)
                }
                SettingsRow(title: "Subscription", detail: "Free Plan", showsChevron: false) {}
                SettingsRow(title: "Units", detail: model.units.rawValue) {
                    model.toggleUnits()
                }
                SettingsRow(title: "Export Data", detail: "CSV") {
                    exportData()
                }
                SettingsRow(title: "Reminders", detail: nil) {}
                SettingsRow(title: "Help & Support", detail: nil, showsDivider: false) {}
            }
            .background(NFTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
                    .presentationDetents([.medium, .large])
            }
        }
        .alert("Could not export data", isPresented: Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportError ?? "Please try again.")
        }
    }

    private func exportData() {
        do {
            exportURL = try DataExportService.makeCSVFile(model: model)
            showingExportSheet = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct MiniProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black))
            Text(label)
                .font(.system(size: 10.5))
                .foregroundStyle(NFTheme.tertiaryText)
        }
        .foregroundStyle(NFTheme.text)
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(NFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private enum DetailStyle {
    case plain
    case premium
}

private struct SettingsRow: View {
    let title: String
    var detail: String?
    var destructive = false
    var detailStyle: DetailStyle = .plain
    var showsDivider = true
    var showsChevron = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(.system(size: 15))
                        .foregroundStyle(destructive ? NFTheme.destructive : NFTheme.text)
                    Spacer()
                    if let detail {
                        Text(detail)
                            .font(.system(size: detailStyle == .premium ? 12 : 14, weight: detailStyle == .premium ? .bold : .regular))
                            .foregroundStyle(detailStyle == .premium ? .white : NFTheme.tertiaryText)
                            .padding(.horizontal, detailStyle == .premium ? 10 : 0)
                            .padding(.vertical, detailStyle == .premium ? 4 : 0)
                            .background(detailStyle == .premium ? AnyShapeStyle(NFTheme.gradient) : AnyShapeStyle(.clear))
                            .clipShape(Capsule())
                    }
                    if !destructive && showsChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(NFTheme.tertiaryText)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)

                if showsDivider {
                    Divider()
                        .background(.white.opacity(0.06))
                        .padding(.leading, 18)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
