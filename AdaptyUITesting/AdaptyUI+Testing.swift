//
//  File.swift
//  
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

#if canImport(UIKit)

import Foundation
import Adapty
import AdaptyUI
import SwiftUI

public extension AdaptyUI.LocalizedViewConfiguration {
    static func createTest(
        templateId: String = "transparent",
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

@available(iOS 13.0, *)
public struct AdaptyUITestRendererView: View {
    var viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    public init(viewConfiguration: AdaptyUI.LocalizedViewConfiguration) {
        self.viewConfiguration = viewConfiguration
    }
    
    public var body: some View {
        if let screen = viewConfiguration.screens.first?.value {
            AdaptyUIElementView(screen.content)
        } else {
            Text("No screens to render")
        }
    }
}

#endif
