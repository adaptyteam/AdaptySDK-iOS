//
//  PaywallNavigationLink.swift
//  AdaptyRecipes-Tuist
//
//  Created by Alexey Goncharov on 1/14/25.
//

import Adapty
import AdaptyUI
import SwiftUI

struct PaywallNavigationLink<Label>: View where Label: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var paywallConfiguration: AdaptyUI.PaywallConfiguration?

    @State private var alertError: IdentifiableErrorWrapper?
    @State private var alertPaywallError: IdentifiableErrorWrapper?

    private var label: () -> Label

    init(
        paywallConfiguration: AdaptyUI.PaywallConfiguration?,
        label: @escaping () -> Label
    ) {
        self.paywallConfiguration = paywallConfiguration
        self.label = label
    }

    var body: some View {
        NavigationLink {
            if let paywallConfiguration {
                AdaptyPaywallView(
                    paywallConfiguration: paywallConfiguration,
                    didFailPurchase: { _, error in
                        alertPaywallError = .init(title: "didFailPurchase error!", error: error)
                    },
                    didFinishRestore: { _ in
                        // handle event
                    },
                    didFailRestore: { error in
                        alertPaywallError = .init(title: "didFailRestore error!", error: error)
                    },
                    didFailRendering: { error in
                        presentationMode.wrappedValue.dismiss()
                        alertPaywallError = .init(title: "didFailRendering error!", error: error)
                    }
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
            }
        } label: {
            label()
        }
    }
}
