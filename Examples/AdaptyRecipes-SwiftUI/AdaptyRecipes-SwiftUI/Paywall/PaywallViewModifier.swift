//
//  PaywallViewModifier.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Adapty
import AdaptyUI
import SwiftUI

struct PaywallViewModifier: ViewModifier {
    private var isPresented: Binding<Bool>
    private var placementId: String
    
    init(isPresented: Binding<Bool>, placementId: String) {
        self.isPresented = isPresented
        self.placementId = placementId
    }
    
    @State var paywall: AdaptyPaywall?
    @State var viewConfig: AdaptyUI.LocalizedViewConfiguration?
    
    @ViewBuilder
    func contentOrSheet(content: Content) -> some View {
        if let paywall, let viewConfig {
            content
                .paywall(
                    isPresented: isPresented,
                    paywall: paywall,
                    viewConfiguration: viewConfig,
                    didFailPurchase: { _, _ in
                        // handle event
                    },
                    didFinishRestore: { _ in
                        // handle event
                    },
                    didFailRestore: { _ in
                        // handle event
                    },
                    didFailRendering: { _ in
                        isPresented.wrappedValue = false
                    }
                )
        } else {
            content
        }
    }
    
    func body(content: Content) -> some View {
        contentOrSheet(content: content)
            .task {
                do {
                    let paywall = try await Adapty.getPaywall(placementId: placementId)
                    let viewConfig = try await AdaptyUI.getViewConfiguration(forPaywall: paywall)
                    
                    self.paywall = paywall
                    self.viewConfig = viewConfig
                } catch {
                    Logger.log(.error, "getPaywallAndConfig: \(error)")
                }
            }
    }
}

extension View {
    func paywall(isPresented: Binding<Bool>, placementId: String) -> some View {
        modifier(
            PaywallViewModifier(
                isPresented: isPresented,
                placementId: placementId
            )
        )
    }
}
