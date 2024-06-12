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
struct AdaptyUIRichTextView: View {
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: AdaptyTagResolverViewModel

    var text: AdaptyUI.RichText
    var productInfo: ProductInfoModel?
    var maxRows: Int?
    var overflowMode: Set<AdaptyUI.Text.OverflowMode>

    init(
        text: AdaptyUI.RichText,
        productInfo: ProductInfoModel?,
        maxRows: Int?,
        overflowMode: Set<AdaptyUI.Text.OverflowMode>
    ) {
        self.text = text
        self.productInfo = productInfo
        self.maxRows = maxRows
        self.overflowMode = overflowMode
    }

    var body: some View {
        text
            .convertToSwiftUIText()
            .lineLimit(maxRows)
            .minimumScaleFactor(overflowMode.contains(.scale) ? 0.5 : 1.0)
    }
}

@available(iOS 15.0, *)
struct AdaptyUITextView: View {
    @EnvironmentObject var productsViewModel: AdaptyProductsViewModel

    var text: AdaptyUI.Text

    init(_ text: AdaptyUI.Text) {
        self.text = text
    }

//    private var attributedString: AttributedString {
//        AttributedString(
//            text.attributedString_legacy(
//                tagResolver: customTagResolverViewModel,
//                productsInfoProvider: productsViewModel
//            )
//        )
//    }

    var body: some View {
        if let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel) {
            AdaptyUIRichTextView(
                text: richText,
                productInfo: productInfo,
                maxRows: text.maxRows,
                overflowMode: text.overflowMode
            )
            .background(Color.yellow)
        } else {
            EmptyView()
        }
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText {
    func convertToSwiftUIText() -> Text {
        var result = Text("")

        for i in 0 ..< items.count {
            let item = items[i]

//            result = result + item.convertToSwiftUIText(isFirstItem: i == 0)
            
            switch item {
            case let .text(value, attr):
                result = result + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr
                    )
                )
            case let .tag(value, attr):
                result = result + Text(value)
            case let .paragraph(attr):
                if i > 0 {
                    result = result + Text("\n")
                }
            case let .image(value, attr):
                result = result + Text("img")
            }
        }

        return result
    }
}

@available(iOS 15.0, *)
extension AdaptyUI.RichText.Item {
    func convertToSwiftUIText(isFirstItem: Bool) -> Text {
        switch self {
        case let .text(value, attr):
            Text(
                AttributedString.createFrom(
                    value: value,
                    attributes: attr
                )
            )
        case let .tag(value, attr):
            Text(value)
        case let .paragraph(attr):
            isFirstItem ? Text("") : Text("\n")
        case let .image(value, attr):
            Text("img")
        }
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

//        if let paragraph {
//            ???
//            package let horizontalAlign: AdaptyUI.HorizontalAlignment
//            package let firstIndent: Double
//            package let indent: Double
//            package let bulletSpace: Double?
//            package let bullet: Bullet?
//            addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
//        }

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
                .paragraph(.create(
                    horizontalAlign: .right
                )),
                .text("Title A!", .testTitleA),
                .paragraph(.create(
                    horizontalAlign: .leading
                )),
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
}
#endif

#endif
