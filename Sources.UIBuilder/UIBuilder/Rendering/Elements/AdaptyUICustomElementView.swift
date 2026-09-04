//
//  AdaptyUICustomElementView.swift
//  AdaptyUIBuilder
//
//  Created by Alex Goncharov on 02/09/2026.
//

#if canImport(UIKit)

import SwiftUI

/// Renders a custom element with the view supplied by the app.
///
/// Observing the view models here is what makes the app view rebuild on flow
/// state updates without the app subscribing to anything.
struct AdaptyUICustomElementView: View {
    private let element: VC.CustomElement

    init(_ element: VC.CustomElement) {
        self.element = element
    }

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @Environment(\.adaptyScreenInstance)
    private var screen: VS.ScreenInstance
    @Environment(\.adaptyShowsDebugPlaceholders)
    private var showsDebugPlaceholders: Bool
    @EnvironmentObject private var assetsViewModel: AdaptyUIAssetsViewModel
    @EnvironmentObject private var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject private var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject private var tagResolverViewModel: AdaptyUITagResolverViewModel
    @EnvironmentObject private var customElementsViewModel: AdaptyUICustomElementsViewModel

    var body: some View {
        if let view = customElementsViewModel.view(forType: element.type, id: element.id, context: context) {
            // Identity by `custom_id` isolates elements from each other: without
            // it, two custom elements taking the same slot of the tree in turn
            // reuse one local state.
            view.id(element.id)
        } else {
            unservedBody
        }
    }

    @ViewBuilder
    private var unservedBody: some View {
        if showsDebugPlaceholders {
            // Colours are fixed rather than inherited: the placeholder has to be
            // readable over whatever the configuration draws behind it.
            Text("custom \(element.type):\(element.id)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.7))
                .cornerRadius(6)
                .onAppear { logUnserved() }
        } else {
            Color.clear
                .frame(width: 0, height: 0)
                .onAppear { logUnserved() }
        }
    }

    private var context: AdaptyUICustomElementContext {
        .init(
            element: element,
            screen: screen,
            colorScheme: colorScheme,
            showsDebugPlaceholders: showsDebugPlaceholders,
            stateRevision: stateViewModel.stateRevision,
            assetsViewModel: assetsViewModel,
            stateViewModel: stateViewModel,
            productsViewModel: productsViewModel,
            tagResolverViewModel: tagResolverViewModel
        )
    }

    private func logUnserved() {
        Log.ui.warn("custom element \(element.type):\(element.id) is not served by a resolver")
    }
}

#endif
