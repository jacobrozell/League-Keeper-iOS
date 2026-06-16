import Foundation

/// Explains pod grouping when attendance count is not a multiple of four.
enum PodLayoutHint {
    static func message(presentCount: Int, podSize: Int = AppConstants.League.podSize) -> String? {
        guard presentCount > 0, presentCount % podSize != 0 else { return nil }
        let remainder = presentCount % podSize
        let fullPods = presentCount / podSize
        if fullPods == 0 {
            return "\(presentCount) present — pods will seat \(presentCount) players."
        }
        let podWord = fullPods == 1 ? "pod" : "pods"
        return "\(presentCount) present — expect \(fullPods) \(podWord) of \(podSize) and 1 pod of \(remainder)."
    }
}
