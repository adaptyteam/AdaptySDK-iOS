//
//  FlowNavigationLink.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Alexey Goncharov on 1/14/25.
//

import Adapty
import AdaptyUI
import SwiftUI

struct FlowNavigationLink<Label>: View where Label: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    private var flowConfiguration: AdaptyUI.FlowConfiguration?

    @State private var alertError: IdentifiableErrorWrapper?
    @State private var alertPaywallError: IdentifiableErrorWrapper?

    private var label: () -> Label

    init(
        flowConfiguration: AdaptyUI.FlowConfiguration?,
        label: @escaping () -> Label
    ) {
        self.flowConfiguration = flowConfiguration
        self.label = label
    }

    var body: some View {
        NavigationLink {
            if let flowConfiguration {
                AdaptyFlowView(
                    flowConfiguration: flowConfiguration,
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
