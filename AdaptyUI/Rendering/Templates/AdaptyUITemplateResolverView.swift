//
//  AdaptyUITemplateResolverView.swift
//
//
//  Created by Aleksey Goncharov on 20.05.2024.
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
package extension AdaptyUI {
    enum Template: String {
        case basic
        case flat
    }
}

// TODO: move to testing
@available(iOS 15.0, *)
package struct AdaptyUIRenderingErrorView: View {
    var text: String
    var forcePresent: Bool

    package init(text: String, forcePresent: Bool = false) {
        self.text = text
        self.forcePresent = forcePresent
    }

    @ViewBuilder
    private var errorView: some View {
        Text("⚠️ " + text)
    }

    package var body: some View {
        #if DEBUG
        errorView
        #else
        if forcePresent {
            errorView
        } else {
            EmptyView()
        }
        #endif
    }
}

@available(iOS 15.0, *)
package struct AdaptyUITemplateResolverView: View {
    var template: AdaptyUI.Template
    var screen: AdaptyUI.Screen

    package init(template: AdaptyUI.Template, screen: AdaptyUI.Screen) {
        self.template = template
        self.screen = screen
    }

    package var body: some View {
        switch template {
        case .basic:
            AdaptyUIBasicContainerView(screen: screen)
        case .flat:
            AdaptyUIFlatContainerView(screen: screen)
        }
    }
}

#endif
