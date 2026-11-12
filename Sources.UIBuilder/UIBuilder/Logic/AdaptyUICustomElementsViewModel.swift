//
//  AdaptyUICustomElementsViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 04/09/2026.
//

#if canImport(UIKit)

import SwiftUI

/// Carries the custom elements resolver to the rendering.
///
/// The resolver passed for a single flow replaces the global one entirely
/// rather than merging with it, so a `custom_type` always resolves through
/// exactly one of the two and the answer to "where did this view come from"
/// stays unambiguous. An app that wants both composes them itself, for example
/// `global.merging(perFlow) { _, perFlow in perFlow }`.
@MainActor
package final class AdaptyUICustomElementsViewModel: ObservableObject, AdaptyUICustomElementsResolver {
    let customElementsResolver: (any AdaptyUICustomElementsResolver)?

    package init(customElementsResolver: (any AdaptyUICustomElementsResolver)?) {
        self.customElementsResolver = customElementsResolver
    }

    package func view(
        forType type: String,
        id: String,
        context: AdaptyUICustomElementContext
    ) -> AnyView? {
        // Resolved on every lookup rather than captured in the initializer: an
        // app that registers the global resolver after the flow configuration
        // is built would otherwise silently get nothing.
        (customElementsResolver ?? AdaptyUIBuilder.customElementsResolver)?
            .view(forType: type, id: id, context: context)
    }
}

#endif
