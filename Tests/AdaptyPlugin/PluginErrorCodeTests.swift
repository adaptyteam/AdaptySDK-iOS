//
//  PluginErrorCodeTests.swift
//  AdaptyTests
//

@testable import AdaptyPlugin
import AdaptyUI
import Testing

struct PluginErrorCodeTests {
    @Test("a failed call keeps the AdaptyUIError code")
    func adaptyUIErrorCodeIsKept() {
        let error = AdaptyPluginError.callFailed(AdaptyUIError.platformNotSupported)

        #expect(error.errorCode == AdaptyUIError.Code.platformNotSupported.rawValue)
    }
}
