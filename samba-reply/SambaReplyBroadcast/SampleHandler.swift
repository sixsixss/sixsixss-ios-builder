import CoreMedia
import ReplayKit
import Vision

final class SampleHandler: RPBroadcastSampleHandler {
    private var lastScan = Date.distantPast
    private let scanInterval: TimeInterval = 1.5

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        SharedStore.transcript = ""
    }

    override func broadcastPaused() {}
    override func broadcastResumed() {}
    override func broadcastFinished() {}

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        let now = Date()
        guard now.timeIntervalSince(lastScan) >= scanInterval else { return }
        lastScan = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-GB", "en-US"]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return
        }

        guard let observations = request.results, !observations.isEmpty else { return }

        let ordered = observations.sorted { lhs, rhs in
            if abs(lhs.boundingBox.midY - rhs.boundingBox.midY) > 0.015 {
                return lhs.boundingBox.midY > rhs.boundingBox.midY
            }
            return lhs.boundingBox.minX < rhs.boundingBox.minX
        }

        var lines: [String] = []
        for observation in ordered {
            // Vision coordinates start at the bottom. Skip the lower screen where the keyboard usually sits.
            guard observation.boundingBox.midY > 0.34 else { continue }
            guard let text = observation.topCandidates(1).first?.string
                .trimmingCharacters(in: .whitespacesAndNewlines), text.count > 1 else { continue }

            let x = observation.boundingBox.midX
            let role: String
            if x >= 0.58 {
                role = "You"
            } else if x <= 0.42 {
                role = "Them"
            } else {
                role = "Screen"
            }
            lines.append("\(role): \(text)")
        }

        guard !lines.isEmpty else { return }
        SharedStore.transcript = lines.suffix(40).joined(separator: "\n")
    }
}
