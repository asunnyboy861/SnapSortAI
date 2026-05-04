import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var isRequestingPermission = false

    private let pages = [
        OnboardingPage(
            icon: "photo.on.rectangle.angled",
            title: "Detect Screenshots",
            description: "SnapSort AI automatically finds all your screenshots and separates them from photos."
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "AI Classification",
            description: "Smart categories like OTP codes, QR codes, receipts, and more - all processed on-device."
        ),
        OnboardingPage(
            icon: "text.magnifyingglass",
            title: "OCR Search",
            description: "Search the actual text inside your screenshots. Find anything in seconds."
        ),
        OnboardingPage(
            icon: "trash.circle",
            title: "Smart Cleanup",
            description: "Temporary screenshots like OTP codes and delivery tracking get cleanup reminders automatically."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    onboardingPage(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 16) {
                if currentPage == pages.count - 1 {
                    Button {
                        requestPermissionAndFinish()
                    } label: {
                        if isRequestingPermission {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Get Started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                } else {
                    Button {
                        withAnimation {
                            currentPage = pages.count - 1
                        }
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 32)
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)

            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func requestPermissionAndFinish() {
        isRequestingPermission = true
        Task {
            let photoKitService = PhotoKitService()
            _ = await photoKitService.requestAuthorization()

            let notificationService = NotificationService()
            _ = await notificationService.requestAuthorization()

            hasCompletedOnboarding = true
            isRequestingPermission = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}
