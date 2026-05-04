import Vision
import UIKit

@Observable
final class OCRService {
    func recognizeText(in image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: " ")

                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant", "ja", "ko", "es", "de", "fr"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    func recognizeText(in asset: PHAsset, photoKitService: PhotoKitService) async -> String {
        guard let image = await photoKitService.loadFullSizeImage(for: asset) else { return "" }
        return await recognizeText(in: image)
    }
}

import Photos
