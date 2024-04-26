//
//  LayoutBuilder+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutProductsBlock(
        _ productsBlock: AdaptyUI.OldProductsBlock,
        initialProducts: [ProductInfoModel],
        paywall: AdaptyPaywall,
        tagConverter: AdaptyUI.CustomTagConverter?,
        in stackView: UIStackView
    ) throws -> ProductsComponentView {
        let productsView: ProductsComponentView

        switch productsBlock.type {
        case .horizontal:
            productsView = try MultipleProductsComponentView(
                axis: .horizontal,
                paywall: paywall,
                products: initialProducts,
                productsBlock: productsBlock,
                tagConverter: tagConverter
            )
        case .vertical:
            productsView = try MultipleProductsComponentView(
                axis: .vertical,
                paywall: paywall,
                products: initialProducts,
                productsBlock: productsBlock,
                tagConverter: tagConverter
            )
        case .single:
            productsView = try SingleProductComponentView(
                product: initialProducts[0],
                productsBlock: productsBlock,
                tagConverter: tagConverter
            )
        }

        stackView.addArrangedSubview(productsView)

        return productsView
    }
}
