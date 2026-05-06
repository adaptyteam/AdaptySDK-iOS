//
//  AdaptyUIRichTextActionHandlerModifier.swift
//
//
//  Created by Alexey Goncharov on 06.05.2026.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
struct AdaptyUIRichTextActionHandlerModifier: ViewModifier {
    @Environment(\.adaptyScreenId)
    private var screenId: String

    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var actionsViewModel: AdaptyUIActionsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel

    private func handle(_ url: URL) -> OpenURLAction.Result {
        do {
            let action = try VC.Action(url: url)
            action.fire(
                screenId: screenId,
                paywallViewModel: paywallViewModel,
                productsViewModel: productsViewModel,
                actionsViewModel: actionsViewModel,
                sectionsViewModel: sectionsViewModel,
                screensViewModel: screensViewModel
            )
            return .handled
        } catch {
            return .systemAction
        }
    }

    func body(content: Content) -> some View {
        content.environment(\.openURL, OpenURLAction(handler: handle))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension View {
    func handleRichTextActionURL() -> some View {
        modifier(AdaptyUIRichTextActionHandlerModifier())
    }
}

#endif
