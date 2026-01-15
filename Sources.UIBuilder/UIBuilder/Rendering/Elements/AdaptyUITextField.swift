//
//  AdaptyUITextField.swift
//  Adapty
//
//  Created by Alex Goncharov on 15/01/2026.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUITextField: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @EnvironmentObject var stateViewModel: AdaptyUIStateViewModel
    @EnvironmentObject var paywallViewModel: AdaptyUIPaywallViewModel
    @EnvironmentObject var productsViewModel: AdaptyUIProductsViewModel
    @EnvironmentObject var sectionsViewModel: AdaptyUISectionsViewModel
    @EnvironmentObject var screensViewModel: AdaptyUIScreensViewModel
    @EnvironmentObject var assetsViewModel: AdaptyUIAssetsViewModel

    private var textField: VC.TextField

    init(_ textField: VC.TextField) {
        self.textField = textField
    }
    
    @State var value = 0.0

    var body: some View {
        TextField(
            "Placeholder",
            text: stateViewModel.createBinding(
                textField.value,
                defaultValue: ""
            )
        )
        .multilineTextAlignment(textField.horizontalAlign)
        .lineLimit(textField.maxRows)
        .minimumScaleFactor(textField.overflowMode.contains(.scale) ? 0.1 : 1.0)
    }
}

#endif
