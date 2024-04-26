//
//  VerticalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

final class VerticalProductInfoView: UIView, ProductInfoView {
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
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceTitleLabel = UILabel()
    private let priceSubtitleLabel = UILabel()
    
    var titleLabelYAxisAnchor: NSLayoutYAxisAnchor { titleLabel.centerYAnchor }
    var subtitleLabelYAxisAnchor: NSLayoutYAxisAnchor { subtitleLabel.centerYAnchor }
    var priceTitleLabelYAxisAnchor: NSLayoutYAxisAnchor { priceTitleLabel.centerYAnchor }
    var priceSubtitleLabelYAxisAnchor: NSLayoutYAxisAnchor { priceSubtitleLabel.centerYAnchor }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false


        titleLabel.minimumScaleFactor = 0.1
        titleLabel.adjustsFontSizeToFitWidth = true
        
        if let title = info.title {
            titleLabel.attributedText = title.attributedString(
                tagConverter: tagConverter,
                productTagConverter: product.tagConverter
            )
            titleLabel.lineBreakMode = .byTruncatingTail
        } else {
            titleLabel.text = " "
        }

        subtitleLabel.numberOfLines = 2
        subtitleLabel.minimumScaleFactor = 0.1
        subtitleLabel.adjustsFontSizeToFitWidth = true

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
        
        priceTitleLabel.minimumScaleFactor = 0.1
        priceTitleLabel.adjustsFontSizeToFitWidth = true
        priceTitleLabel.attributedText = info.secondTitle?.attributedString(
            tagConverter: tagConverter,
            productTagConverter: product.tagConverter
        )

        priceSubtitleLabel.minimumScaleFactor = 0.1
        priceSubtitleLabel.adjustsFontSizeToFitWidth = true
        priceSubtitleLabel.attributedText = info.secondSubitle?.attributedString(
            tagConverter: tagConverter,
            productTagConverter: product.tagConverter
        )
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(priceTitleLabel)
        addSubview(priceSubtitleLabel)

        addConstraints([
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),

            subtitleLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 0.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            
            priceTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 8.0),
            priceTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            priceTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
                        
            priceSubtitleLabel.topAnchor.constraint(greaterThanOrEqualTo: priceTitleLabel.bottomAnchor, constant: 0.0),
            priceSubtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            priceSubtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            priceSubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16.0),
        ])
    }
}
