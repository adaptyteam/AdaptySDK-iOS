//
//  AdaptyUIBuilder+UI.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public extension View {
    func paywall<Placeholder: View>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = true,
        paywallConfiguration: AdaptyUIBuilder.PaywallConfiguration?,
        didAppear: (() -> Void)? = nil,
        didDisappear: (() -> Void)? = nil,
        didPerformAction: ((AdaptyUIBuilder.Action) -> Void)? = nil,
        didSelectProduct: ((ProductResolver) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFailRendering: @escaping (AdaptyUIBuilderError) -> Void,
        placeholderBuilder: (() -> Placeholder)?
    ) -> some View {
        EmptyView()
    }
}
