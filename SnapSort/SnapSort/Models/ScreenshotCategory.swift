import Foundation
import SwiftData

enum ScreenshotCategory: String, CaseIterable, Codable {
    case otp = "OTP & Verification"
    case qrCode = "QR Codes"
    case delivery = "Delivery & Tracking"
    case receipt = "Receipts & Payments"
    case social = "Social Media"
    case notes = "Notes & Text"
    case shopping = "Shopping & Products"
    case travel = "Travel & Maps"
    case food = "Recipes & Food"
    case work = "Work & Documents"
    case meme = "Memes & Fun"
    case health = "Health & Fitness"
    case other = "Other"

    var icon: String {
        switch self {
        case .otp: return "lock.shield"
        case .qrCode: return "qrcode"
        case .delivery: return "shippingbox"
        case .receipt: return "receipt"
        case .social: return "message"
        case .notes: return "note.text"
        case .shopping: return "bag"
        case .travel: return "map"
        case .food: return "fork.knife"
        case .work: return "briefcase"
        case .meme: return "face.smiling"
        case .health: return "heart.text.square"
        case .other: return "square.grid.2x2"
        }
    }

    var color: String {
        switch self {
        case .otp: return "FF3B30"
        case .qrCode: return "5856D6"
        case .delivery: return "FF9500"
        case .receipt: return "34C759"
        case .social: return "007AFF"
        case .notes: return "8E8E93"
        case .shopping: return "AF52DE"
        case .travel: return "00C7BE"
        case .food: return "FF2D55"
        case .work: return "007AFF"
        case .meme: return "FFCC00"
        case .health: return "FF375F"
        case .other: return "8E8E93"
        }
    }

    var isTemporary: Bool {
        [.otp, .qrCode, .delivery].contains(self)
    }

    var isPremium: Bool {
        ![.otp, .qrCode, .delivery, .other].contains(self)
    }
}
