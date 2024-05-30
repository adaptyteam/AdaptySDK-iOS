//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI

@available(iOS 15.0, *)
struct AdaptyUITextView: View {
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyTagResolverViewModel

    var text: AdaptyUI.Text

    init(_ text: AdaptyUI.Text) {
        self.text = text
    }

    private var attributedString: AttributedString {
        AttributedString(
            text.attributedString(
                tagResolver: customTagResolverViewModel,
                productsInfoProvider: productsViewModel
            )
        )
    }

    var body: some View {
        Text(attributedString)
    }
}

#if DEBUG

@available(iOS 15.0, *)
#Preview {
    AdaptyUITextView(.testBodyLong)
        .background(Color.yellow)
        .environmentObject(AdaptyProductsViewModel(logId: "Preview"))
        .environmentObject(AdaptyUIActionsViewModel(logId: "Preview"))
        .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
        .environmentObject(AdaptyTagResolverViewModel(tagResolver: ["TEST_TAG": "Adapty"]))
}
#endif

#endif
