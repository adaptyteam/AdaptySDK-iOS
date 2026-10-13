//
//  AdaptyUICustomElementsResolver.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 02/09/2026.
//

#if canImport(UIKit)

import SwiftUI

/// Supplies the view that renders a custom element of the flow.
///
/// Pass an implementation as `customElementsResolver` when building the flow
/// configuration. Returning `nil` means the element is not served by the app:
/// nothing is rendered in release builds, and a diagnostic placeholder is
/// rendered when `showsDebugPlaceholders` is on.
///
/// For the common case pass a `[String: AdaptyUICustomElementBuilder]` keyed by
/// `custom_type` — the dictionary already conforms to this protocol.
@MainActor
public protocol AdaptyUICustomElementsResolver {
    /// - Parameters:
    ///   - type: `custom_type` of the element as declared in the configuration.
    ///   - id: `custom_id` of the element, unique within the configuration.
    ///   - context: access to the payload of the element and to the flow.
    func view(
        forType type: String,
        id: String,
        context: AdaptyUICustomElementContext
    ) -> AnyView? // consider ViewBuilder + UIKit Resolver with `update` protocol.
}

/// Builds the view of a single custom element type.
///
/// The concrete view type is erased inside the SDK, so the closure can return
/// any view without naming an erasing type at the call site:
///
/// ```swift
/// let resolver: [String: AdaptyUICustomElementBuilder] = [
///     "rating": .init { _, _, context in
///         if let title = context.string("title") {
///             Text(title)
///         }
///     },
/// ]
/// ```
///
/// Two constraints follow from type erasure and from how SwiftUI matches views
/// between updates:
///
/// - Branch **inside** one view rather than between different view types
///   returned from the closure. A closure that returns `RatingView` in one
///   state and `Text` in another loses view identity on every switch, and the
///   local state of the app view is reset. Keep the branching inside a single
///   view of the app.
/// - Keep the closure cheap. It runs on every flow state update, so heavy
///   state — players, network clients — belongs in the state of the app view,
///   not in the closure.
public struct AdaptyUICustomElementBuilder {
    let build: @MainActor (String, String, AdaptyUICustomElementContext) -> AnyView

    public init<Content: View>(
        @ViewBuilder _ build: @escaping @MainActor (
            _ type: String,
            _ id: String,
            _ context: AdaptyUICustomElementContext
        ) -> Content
    ) {
        self.build = { type, id, context in
            AnyView(build(type, id, context))
        }
    }
}

extension [String: AdaptyUICustomElementBuilder]: AdaptyUICustomElementsResolver {
    public func view(
        forType type: String,
        id: String,
        context: AdaptyUICustomElementContext
    ) -> AnyView? {
        self[type]?.build(type, id, context)
    }
}

@MainActor
extension AdaptyUIBuilder {
    package private(set) static var customElementsResolver: (any AdaptyUICustomElementsResolver)?

    /// Resolver used by every flow that does not carry its own. The public
    /// entry point is `AdaptyUI.setCustomElementsResolver(_:)`: this module is
    /// exported only because the public API of `AdaptyUI` names its types.
    package static func setCustomElementsResolver(_ resolver: (any AdaptyUICustomElementsResolver)?) {
        customElementsResolver = resolver
    }
}

#endif
