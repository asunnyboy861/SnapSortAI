import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("cleanupReminderDays") private var cleanupReminderDays = 3
    @AppStorage("faceIDEnabled") private var faceIDEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var showPaywall = false
    @State private var showContactSupport = false

    @State private var purchaseManager = PurchaseManager()

    var body: some View {
        NavigationStack {
            Form {
                premiumSection
                managementSection
                notificationSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    private var premiumSection: some View {
        Section {
            if purchaseManager.isPremium {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                    Text("Premium Active")
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Premium")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Subscription")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
    }

    private var managementSection: some View {
        Section {
            Stepper(
                "Cleanup after \(cleanupReminderDays) day\(cleanupReminderDays == 1 ? "" : "s")",
                value: $cleanupReminderDays,
                in: 1...30
            )
        } header: {
            Text("Screenshot Management")
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("Cleanup Reminders", isOn: $notificationsEnabled)
        } header: {
            Text("Notifications")
        }
    }

    private var privacySection: some View {
        Section {
            Toggle("Face ID Protection", isOn: $faceIDEnabled)
        } header: {
            Text("Privacy")
        } footer: {
            Text("When enabled, sensitive categories (OTP, Receipts) require Face ID to view.")
        }
    }

    private var aboutSection: some View {
        Section {
            Button {
                showContactSupport = true
            } label: {
                HStack {
                    Image(systemName: "envelope")
                    Text("Contact Support")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/SnapSortAI/support.html")!) {
                HStack {
                    Image(systemName: "questionmark.circle")
                    Text("Support Page")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/SnapSortAI/privacy.html")!) {
                HStack {
                    Image(systemName: "hand.raised")
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Link(destination: URL(string: "https://asunnyboy861.github.io/SnapSortAI/terms.html")!) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Terms of Use")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !purchaseManager.isPremium {
                Button {
                    Task {
                        await purchaseManager.restorePurchases()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Restore Purchases")
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            HStack {
                Spacer()
                Text("SnapSort AI v1.0")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .sheet(isPresented: $showContactSupport) {
            ContactSupportView()
        }
    }
}
