//
//  MultipleProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.7.23..
//

import Adapty
import UIKit

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

final class MultipleProductsComponentView: UIStackView, ProductsComponentView {
    private let paywall: AdaptyPaywall
    private var products: [ProductInfoModel]
    private let productsBlock: AdaptyUI.OldProductsBlock
    private let tagConverter: AdaptyUI.CustomTagConverter?

    var onProductSelected: ((ProductInfoModel) -> Void)?

    init(
        axis: NSLayoutConstraint.Axis,
        paywall: AdaptyPaywall,
        products: [ProductInfoModel],
        productsBlock: AdaptyUI.OldProductsBlock,
        tagConverter: AdaptyUI.CustomTagConverter?
    ) throws {
        self.paywall = paywall
        self.products = products
        self.productsBlock = productsBlock
        self.tagConverter = tagConverter

        super.init(frame: .zero)

        self.axis = axis

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .fill
        distribution = .fillEqually
        spacing = 8.0

        let selectedId = products[safe: productsBlock.mainProductIndex]?.id
        try populateProductsButtons(products, selectedId: selectedId)
    }

    private var purchaseButtons = [AdaptyButtonComponentView]()

    private func cleanupView() {
        purchaseButtons.removeAll()

        let views = arrangedSubviews

        for view in views {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func populateProductsButtons(_ products: [ProductInfoModel], selectedId: String?) throws {
        var previousProductInfoView: ProductInfoView?

        let orderedProducts = productsBlock.products(by: paywall)

        for i in 0 ..< products.count {
            let product = products[i]
            let productInfo: AdaptyUI.ProductInfo

            if let adaptyProduct = product.adaptyProduct {
                if let info = productsBlock.product(by: adaptyProduct)?.toProductInfo(id: product.id) {
                    productInfo = info
                } else {
                    throw AdaptyUIError.componentNotFound("\(product.id):product_info")
                }
            } else {
                if let info = orderedProducts[safe: i]?.toProductInfo(id: product.id) {
                    productInfo = info
                } else {
                    throw AdaptyUIError.componentNotFound("\(product.id):product_info")
                }
            }

            let productView = UIView()
            addArrangedSubview(productView)

            let (button, productInfoView) = try buildProductItemView(
                on: productView,
                blockType: productsBlock.type,
                product: product,
                productInfo: productInfo,
                isSelected: product.id == selectedId
            )

            purchaseButtons.append(button)

            switch productsBlock.type {
            case .horizontal:
                guard let previousView = previousProductInfoView as? VerticalProductInfoView,
                      let currentView = productInfoView as? VerticalProductInfoView else { break }

                addConstraints([
                    currentView.titleLabelYAxisAnchor.constraint(equalTo: previousView.titleLabelYAxisAnchor),
                    currentView.subtitleLabelYAxisAnchor.constraint(equalTo: previousView.subtitleLabelYAxisAnchor),
                    currentView.priceTitleLabelYAxisAnchor.constraint(equalTo: previousView.priceTitleLabelYAxisAnchor),
                    currentView.priceSubtitleLabelYAxisAnchor.constraint(equalTo: previousView.priceSubtitleLabelYAxisAnchor),
                ])
            default:
                alignment = .fill
                addConstraint(productView.heightAnchor.constraint(equalToConstant: 64.0))
            }

            previousProductInfoView = productInfoView
        }
    }

    private func buildProductItemView(
        on containerView: UIView,
        blockType: AdaptyUI.ProductsBlockType,
        product: ProductInfoModel,
        productInfo: AdaptyUI.ProductInfo,
        isSelected: Bool
    ) throws -> (AdaptyButtonComponentView, ProductInfoView) {
        guard let buttonComponent = productInfo.button else {
            throw AdaptyUIError.componentNotFound("product_info.button")
        }

        let productInfoView: ProductInfoView
        let contentViewMargins: UIEdgeInsets

        switch blockType {
        case .horizontal:
            contentViewMargins = .zero
            productInfoView = try VerticalProductInfoView(product: product,
                                                          info: productInfo,
                                                          tagConverter: tagConverter)
        default:
            contentViewMargins = .init(top: 12, left: 20, bottom: 12, right: 20)
            productInfoView = try HorizontalProductInfoView(product: product,
                                                            info: productInfo,
                                                            tagConverter: tagConverter)
        }

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = false

        let button = AdaptyButtonComponentView(
            component: buttonComponent,
            tagConverter: tagConverter,
            contentView: productInfoView,
            contentViewMargins: contentViewMargins,
            onTap: { [weak self] _ in self?.onProductSelected?(product) }
        )
        button.isSelected = isSelected

        containerView.addSubview(button)
        containerView.addConstraints([
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        if let tagText = productInfo.tagText {
            let tagView = try ProductBadgeView(text: tagText,
                                               shape: productInfo.tagShape,
                                               tagConverter: tagConverter)

            containerView.addSubview(tagView)

            switch blockType {
            case .horizontal:
                addConstraints([
                    tagView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    tagView.centerYAnchor.constraint(equalTo: containerView.topAnchor),
                ])
            default:
                addConstraints([
                    tagView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0),
                    tagView.centerYAnchor.constraint(equalTo: containerView.topAnchor),
                ])
            }
        }

        return (button, productInfoView)
    }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) throws {
        self.products = products

        cleanupView()
        try setupView()
    }

    func updateSelectedState(_ productId: String) {
        guard let index = products.firstIndex(where: { $0.id == productId }) else {
            return
        }

        for i in 0 ..< purchaseButtons.count {
            guard let subview = purchaseButtons[safe: i] else { continue }
            subview.isSelected = i == index
        }
    }
}
