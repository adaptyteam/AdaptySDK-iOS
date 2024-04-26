//
//  HorizontalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import Adapty
import UIKit

final class HorizontalProductInfoView: UIStackView, ProductInfoView {
    let product: ProductInfoModel
    let info: AdaptyUI.ProductInfo
    let tagConverter: AdaptyUI.CustomTagConverter?
    
    init(product: ProductInfoModel,
         info: AdaptyUI.ProductInfo,
         tagConverter: AdaptyUI.CustomTagConverter?) throws {
        self.product = product
        self.info = info
        self.tagConverter = tagConverter

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if let title = info.title {
            titleLabel.attributedText = title.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
        } else {
            titleLabel.text = " "
        }

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.1
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

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
            if let subtitle = info.subtitle {
                subtitleLabel.attributedText = subtitle.attributedString(
                    tagConverter: tagConverter,
                    productTagConverter: product.tagConverter
                )
            } else {
                subtitleLabel.text = " "
            }
        }

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceTitleLabel.adjustsFontSizeToFitWidth = true
        priceTitleLabel.minimumScaleFactor = 0.1
        priceTitleLabel.attributedText = info.secondTitle?.attributedString(
            tagConverter: tagConverter,
            productTagConverter: product.tagConverter
        )

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceSubtitleLabel.adjustsFontSizeToFitWidth = true
        priceSubtitleLabel.minimumScaleFactor = 0.1
        priceSubtitleLabel.attributedText = info.secondSubitle?.attributedString(
            tagConverter: tagConverter,
            productTagConverter: product.tagConverter
        )

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

        let noSubtitle = subtitleLabel.attributedText?
            .string
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        let noSecondSubtitle = priceSubtitleLabel.attributedText?
            .string
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true

        let subtitleStack = UIStackView(arrangedSubviews: [subtitleLabel, priceSubtitleLabel])
        subtitleStack.translatesAutoresizingMaskIntoConstraints = false
        subtitleStack.axis = .horizontal
        subtitleStack.spacing = 4.0
        subtitleStack.isHidden = noSubtitle && noSecondSubtitle

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 0.0
        alignment = .fill

        addArrangedSubview(titleStack)
        addArrangedSubview(subtitleStack)
    }
}
