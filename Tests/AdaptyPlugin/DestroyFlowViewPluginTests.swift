//
//  DestroyFlowViewPluginTests.swift
//  AdaptyTests
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import Foundation
import Testing

@MainActor
struct DestroyFlowViewPluginTests {
    @Test("destroying an id that is not cached reports viewNotFound")
    func unknownViewIdIsReported() async {
        let viewId = "00000000-0000-0000-0000-000000000000"

        let error = await #expect(throws: AdaptyError.self) {
            try await AdaptyUI.Plugin.destroyFlowView(viewId: viewId)
        }

        #expect(error?.adaptyErrorCode == .wrongParam)
    }
}

#endif
