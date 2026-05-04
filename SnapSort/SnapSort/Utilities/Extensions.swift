import SwiftUI

extension View {
    func frameForiPad(maxWidth: CGFloat = 720) -> some View {
        self.frame(maxWidth: maxWidth).frame(maxWidth: .infinity)
    }
}

extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension ScreenshotCategory: Identifiable {
    var id: String { rawValue }
}
