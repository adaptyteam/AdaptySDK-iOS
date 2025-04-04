//
//  OnboArdings+OnboardingView.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import UIKit

extension Onboardings {
    static func getOnboardingURL(id: String) async throws -> URL {
        let instance = try await activated
        return instance.configuration.onboardingUrl(onboardingId: id)
    }
    
    @MainActor
    func createOnboardingController(
        id: String,
        delegate: OnboardingDelegate
    ) throws -> OnboardingController {
        let url = configuration.onboardingUrl(onboardingId: id)

        let vc = OnboardingController(
            url: url,
            delegate: delegate
        )

        return vc
    }
}
