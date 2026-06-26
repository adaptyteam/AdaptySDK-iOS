//
//  AdaptyUIBuilder+RequestAppReview.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import StoreKit
import UIKit

package extension AdaptyUIBuilder {
    @MainActor
    static func requestAppReview() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

#endif
