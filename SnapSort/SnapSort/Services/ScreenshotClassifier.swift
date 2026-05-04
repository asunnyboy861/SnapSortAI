import Vision
import UIKit

@Observable
final class ScreenshotClassifier {
    private let textClassifier = TextBasedClassifier()
    private let imageClassifier = ImageBasedClassifier()

    func classify(image: UIImage, extractedText: String) async -> ScreenshotCategory {
        if isOTP(text: extractedText) { return .otp }
        if await isQRCode(image: image) { return .qrCode }
        if isDeliveryTracking(text: extractedText) { return .delivery }
        if isReceipt(text: extractedText) { return .receipt }

        let textCategory = textClassifier.classify(text: extractedText)
        let imageCategory = await imageClassifier.classify(image: image)

        if let text = textCategory { return text }
        if let image = imageCategory { return image }
        return .other
    }

    private func isOTP(text: String) -> Bool {
        let otpPatterns = [
            "\\b\\d{4,8}\\b",
            "(?i)verification\\s*code",
            "(?i)OTP",
            "(?i)confirm(?:ation)?\\s*code",
            "(?i)security\\s*code",
            "(?i)authentication\\s*code",
            "(?i)two.factor",
            "(?i)2FA",
            "(?i)enter.*code",
            "(?i)your code is"
        ]
        return otpPatterns.contains { text.range(of: $0, options: .regularExpression) != nil }
    }

    private func isQRCode(image: UIImage) async -> Bool {
        guard let cgImage = image.cgImage else { return false }

        return await withCheckedContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                let hasBarcodes = !(request.results?.isEmpty ?? true)
                continuation.resume(returning: hasBarcodes)
            }
            request.symbologies = [.qr, .aztec, .pdf417]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    private func isDeliveryTracking(text: String) -> Bool {
        let patterns = [
            "(?i)tracking\\s*(?:number|code|id)",
            "(?i)order\\s*(?:status|confirmed|shipped|delivered)",
            "(?i)estimated\\s*delivery",
            "(?i)1Z[A-Z0-9]{16}",
            "(?i)FedEx|UPS|USPS|DHL|Amazon|Deliver",
            "(?i)package|shipment|out for delivery"
        ]
        return patterns.contains { text.range(of: $0, options: .regularExpression) != nil }
    }

    private func isReceipt(text: String) -> Bool {
        let patterns = [
            "(?i)total\\s*:\\s*\\$",
            "(?i)subtotal|sub\\s*total",
            "(?i)payment\\s*(?:method|received)",
            "(?i)receipt|invoice",
            "\\$\\d+\\.\\d{2}",
            "(?i)change due|amount paid|card ending"
        ]
        return patterns.filter { text.range(of: $0, options: .regularExpression) != nil }.count >= 2
    }
}

final class TextBasedClassifier {
    private let categoryKeywords: [ScreenshotCategory: [String]] = [
        .social: ["instagram", "twitter", "tiktok", "facebook", "snapchat", "whatsapp", "message from", "dm me", "follow", "like", "share post"],
        .shopping: ["add to cart", "checkout", "price", "discount", "sale", "buy now", "shop", "order", "$", "cart", "wishlist", "deal"],
        .travel: ["flight", "hotel", "booking", "reservation", "boarding pass", "gate", "terminal", "airbnb", "check-in", "departure"],
        .food: ["recipe", "ingredients", "cook", "bake", "minutes", "oven", "tablespoon", "cup of", "tsp", "tbsp", "preheat"],
        .work: ["meeting", "deadline", "project", "sprint", "jira", "slack", "email", "report", "standup", "sprint", "kanban"],
        .health: ["doctor", "appointment", "medication", "blood pressure", "calories", "workout", "steps", "heart rate", "sleep"],
        .meme: ["lol", "lmao", "bruh", "when you", "nobody:", "me:", "mood", "relatable", "fr fr"]
    ]

    func classify(text: String) -> ScreenshotCategory? {
        let lowercased = text.lowercased()
        var bestMatch: ScreenshotCategory?
        var bestScore = 0

        for (category, keywords) in categoryKeywords {
            let score = keywords.filter { lowercased.contains($0) }.count
            if score > bestScore {
                bestScore = score
                bestMatch = category
            }
        }
        return bestMatch
    }
}

final class ImageBasedClassifier {
    func classify(image: UIImage) async -> ScreenshotCategory? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                let topObservations = observations.prefix(10)
                let categories = topObservations.compactMap { obs -> ScreenshotCategory? in
                    self.mapVisionCategory(obs.identifier, confidence: obs.confidence)
                }
                continuation.resume(returning: categories.first)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    private func mapVisionCategory(_ identifier: String, confidence: Float) -> ScreenshotCategory? {
        guard confidence > 0.3 else { return nil }

        if identifier.contains("food") || identifier.contains("cuisine") { return .food }
        if identifier.contains("travel") || identifier.contains("landscape") { return .travel }
        if identifier.contains("receipt") || identifier.contains("document") { return .receipt }
        if identifier.contains("people") || identifier.contains("person") { return .social }

        return nil
    }
}
