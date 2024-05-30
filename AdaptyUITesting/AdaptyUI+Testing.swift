//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

#if canImport(UIKit)

import Adapty
import AdaptyUI
import Foundation
import SwiftUI

public extension AdaptyUI.LocalizedViewConfiguration {
    static func createTest(
        templateId: String = "basic",
        locale: String = "en",
        isRightToLeft: Bool = false,
        images: [String] = [],
        colors: [String: String] = [:],
        strings: [String: String] = [:],
        content: String
    ) throws -> Self {
        try create(templateId: templateId,
                   locale: locale,
                   isRightToLeft: isRightToLeft,
                   images: images,
                   colors: colors,
                   strings: strings,
                   content: content)
    }
}

@available(iOS 15.0, *)
public enum AdaptyUIPreviewRenderingMode: String, CaseIterable {
    case template
    case element
}

@available(iOS 15.0, *)
public struct AdaptyUITestRendererView: View {
    var viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    var renderingMode: AdaptyUIPreviewRenderingMode

    public init(viewConfiguration: AdaptyUI.LocalizedViewConfiguration, renderingMode: AdaptyUIPreviewRenderingMode) {
        self.viewConfiguration = viewConfiguration
        self.renderingMode = renderingMode
    }

    @ViewBuilder
    private func drawAsElement(screen: AdaptyUI.Screen) -> some View {
        AdaptyUIElementView(screen.content)
    }

    public var body: some View {
         let screen = viewConfiguration.screen
            switch renderingMode {
            case .template:
                if let template = AdaptyUI.Template(rawValue: viewConfiguration.templateId) {
                    AdaptyUITemplateResolverView(
                        template: template,
                        screen: screen,
                        isRightToLeft: viewConfiguration.isRightToLeft
                    )
                    .environmentObject(AdaptyUIActionsViewModel(logId: "AdaptyUITesting"))
                    .environmentObject(AdaptySectionsViewModel(logId: "AdaptyUITesting"))
                } else {
                    AdaptyUIRenderingErrorView(text: "Wrong templateId: \(viewConfiguration.templateId)", forcePresent: true)
                }
            case .element:
                AdaptyUIElementView(screen.content)
                    .environmentObject(AdaptyUIActionsViewModel(logId: "AdaptyUITesting"))
            }
     
    }
}

#endif
