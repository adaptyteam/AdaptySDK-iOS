//
//  Plugin+SystemActions.swift
//  Adapty
//

import Adapty
import AdaptyUIBuilder
import Foundation

@MainActor
extension AdaptyUI.Plugin {
    package static func openURL(_ url: URL, in presentation: AdaptyWebPresentation) async {
        #if canImport(UIKit)
        _ = await url.open(presentation: presentation)
        #endif
    }

    package static func requestAppReview() async {
        #if canImport(UIKit)
        AdaptyUIBuilder.requestAppReview()
        #endif
    }
}
