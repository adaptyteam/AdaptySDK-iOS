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

    var body: some View {
        if let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel) {
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: productInfo
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.5 : 1.0)
            .background(Color.yellow)
        } else {
            EmptyView()
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    func convertToSwiftUIText(
        tagResolver: AdaptyTagResolver,
        productInfo: ProductInfoModel?
    ) -> Text {
        var result = Text("")

        for item in items {
            switch item {
            case let .text(value, attr):
                result = result + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr
                    )
                )
            case let .tag(value, attr):
                let tagReplacementResult: String

                if let customTagResult = tagResolver.replacement(for: value) {
                    tagReplacementResult = customTagResult
                } else if let productTag = AdaptyUI.ProductTag(rawValue: value),
                          let productTagResult = productInfo?.stringByTag(productTag)
                {
                    switch productTagResult {
                    case .notApplicable:
                        tagReplacementResult = ""
                    case let .value(string):
                        tagReplacementResult = string
                    }

                } else {
                    tagReplacementResult = ""
                }
                
                result = result + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        attributes: attr
                    )
                )
            case let .image(value, attr):
                result = result + Text("img")
            }
        }

        return result
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Text {
    func extract(productsInfoProvider: ProductsInfoProvider) -> (AdaptyUI.RichText, ProductInfoModel?)? {
        switch value {
        case let .text(value):
            return (value, nil)
        case let .productText(value):
            guard let product = productsInfoProvider.productInfo(by: value.adaptyProductId) else {
                // TODO: inspect, shimmer?
                return nil
            }

            return (value.richText(byPaymentMode: product.paymentMode), product)
        case let .selectedProductText(value):
            guard let product = productsInfoProvider.selectedProductInfo, let adaptyProductId = product.adaptyProduct?.adaptyProductId else {
                return (value.richText(), nil)
            }

            return (value.richText(adaptyProductId: adaptyProductId, byPaymentMode: product.paymentMode), product)
        }
    }
}

@available(iOS 15.0, *)
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> AttributedString {
        var result = AttributedString(value)

        result.foregroundColor = attributes?.uiColor ?? .darkText
        result.font = attributes?.uiFont ?? .systemFont(ofSize: 15.0) // TODO: move to constant

        if let background = attributes?.background?.asColor {
            result.backgroundColor = background.swiftuiColor
        }

        if attributes?.strike ?? false {
            result.strikethroughStyle = .single
        }

        if attributes?.underline ?? false {
            result.underlineStyle = .single
        }

        return result
    }
}

#if DEBUG

@available(iOS 15.0, *)
extension AdaptyUI.RichText.TextAttributes {
    static var testTitleA: Self {
        .create(
            font: .default,
            size: 24.0,
            txtColor: .color(.testRed),
            imgTintColor: nil,
            background: nil,
            strike: false,
            underline: false
        )
    }

    static var testBodyA: Self {
        .create(
            font: .default,
            size: 17.0,
            txtColor: .color(.testBlue),
            imgTintColor: nil,
            background: nil,
            strike: false,
            underline: false
        )
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    static var testTitleA: Self {
        .create(
            
            items: [
                .text("Title A!", .testTitleA),
                .text("Body A, Body A, Body A\nBody AAA Body AAA Body AAA Body AAA Body AAA", .testBodyA),
            ]
        )
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.Text {
    static var testTitle: Self {
        .create(
            value: .text(.testTitleA),
            horizontalAlign: .justified,
            maxRows: nil,
            overflowMode: [.scale]
        )
    }
}

@available(iOS 15.0, *)
#Preview {
    AdaptyUITextView(.testTitle)
//        .background(Color.yellow)
        .environmentObject(AdaptyProductsViewModel(logId: "Preview"))
        .environmentObject(AdaptyUIActionsViewModel(logId: "Preview"))
        .environmentObject(AdaptySectionsViewModel(logId: "Preview"))
        .environmentObject(AdaptyTagResolverViewModel(tagResolver: ["TEST_TAG": "Adapty"]))
        .environment(\.layoutDirection, .leftToRight)
}
#endif

#endif
