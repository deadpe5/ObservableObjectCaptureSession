import Foundation
import RealityKit
import SwiftUI

/// Keeps the UI string conversions all in one place for simplicity
final class FeedbackMessages {
    /// Returns the human readable string to display for the given feedback.
    static func getFeedbackString(for feedback: ObjectCaptureSession.Feedback) -> String? {
        switch feedback {
        case .objectTooClose:
            return "Move Farther Away"
        case .objectTooFar:
            return "Move Closer"
        case .movingTooFast:
            return "Move Slower"
        case .environmentLowLight, .environmentTooDark:
            return "More Light Required"
        case .outOfFieldOfView:
            return "Aim at your Object"
        default:
            return nil
        }
    }
}
