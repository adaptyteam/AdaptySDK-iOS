//
//  SingleProductComponentView.swift
//
//
//  Created by Alexey Goncharov on 9.8.23..
//

import Adapty
import UIKit

final class SingleProductComponentView: UIStackView, ProductsComponentView {
    var onProductSelected: ((ProductInfoModel) -> Void)?

    private var product: ProductInfoModel
    private let info: AdaptyUI.ProductInfo
    private let tagConverter: AdaptyUI.CustomTagConverter?

    init(
        product: ProductInfoModel,
        productsBlock: AdaptyUI.OldProductsBlock,
        tagConverter: AdaptyUI.CustomTagConverter?
    ) throws {
        guard productsBlock.type == .single else {
            throw AdaptyUIError.wrongComponentType("products_block")
        }

        self.product = product
        self.tagConverter = tagConverter

        if let adaptyProduct = product.adaptyProduct,
           let productInfo = productsBlock.product(by: adaptyProduct)?.toProductInfo(id: product.id) {
            info = productInfo
        } else if let productInfo = productsBlock.products.first?.value.toProductInfo(id: product.id) {
            info = productInfo
        } else {
            throw AdaptyUIError.componentNotFound("\(product.id):product_info")
        }

        super.init(frame: .zero)

        try setupView()
        try updateProducts([product], selectedProductId: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var titleLabel: UILabel!
    private weak var subtitleLabel: UILabel!
    private weak var descriptionLabel: UILabel!

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 4.0

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        let bottomStackView = UIStackView(arrangedSubviews: [subtitleLabel, descriptionLabel])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 0.0

        addArrangedSubview(titleLabel)
        addArrangedSubview(bottomStackView)

        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.descriptionLabel = descriptionLabel
    }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) throws {
        guard let product = products.first else { return }

        if let title = info.title?.attributedString(tagConverter: tagConverter,
                                                    productTagConverter: product.tagConverter) {
            titleLabel.attributedText = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }

        switch product.eligibleOffer?.paymentMode {
        case .payAsYouGo:
            subtitleLabel.attributedText = info.subtitlePayAsYouGo?.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
        case .payUpFront:
            subtitleLabel.attributedText = info.subtitlePayUpFront?.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
        case .freeTrial:
            subtitleLabel.attributedText = info.subtitleFreeTrial?.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
        default:
            subtitleLabel.attributedText = info.subtitle?.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
        }

        if let secondTitle = info.secondTitle?.attributedString(
            tagConverter: tagConverter,
            productTagConverter: product.tagConverter
        ) {
            descriptionLabel.attributedText = secondTitle
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }

    func updateSelectedState(_ productId: String) { }
}
