//
//  TemplateLayoutBuilderBasic.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Decorator {
    fileprivate var recommendedContentOverlap: CGFloat {
        switch shapeType {
        case let .rectangle(cornerRadius): return max(24.0, cornerRadius.topLeft)
        case .curveUp: return 1.5 * AdaptyBaseContentView.curveHeight
        case .curveDown: return 0.8 * AdaptyBaseContentView.curveHeight
        case .circle: return 0.0
        }
    }
}

class TemplateLayoutBuilderBasic: LayoutBuilder {
    private let coverImage: AdaptyUI.ImageData
    private let coverImageHeightMultilpyer: CGFloat
    private let contentShape: AdaptyUI.Decorator
    private let titleRows: AdaptyUI.RichText?
    private let featuresBlock: AdaptyUI.OldFeaturesBlock?
    private let productsBlock: AdaptyUI.OldProductsBlock
    private let purchaseButton: AdaptyUI.OldButton
    private let purchaseButtonOfferTitle: AdaptyUI.RichText?
    private let closeButton: AdaptyUI.OldButton?
    private let footerBlock: AdaptyUI.OldFooterBlock?
    private let initialProducts: [ProductInfoModel]
    private let paywall: AdaptyPaywall
    private let tagConverter: AdaptyUI.CustomTagConverter?

    private let scrollViewDelegate = AdaptyCompoundScrollViewDelegate()

    init(
        coverImage: AdaptyUI.ImageData,
        coverImageHeightMultilpyer: CGFloat,
        contentShape: AdaptyUI.Decorator,
        titleRows: AdaptyUI.RichText?,
        featuresBlock: AdaptyUI.OldFeaturesBlock?,
        productsBlock: AdaptyUI.OldProductsBlock,
        purchaseButton: AdaptyUI.OldButton,
        purchaseButtonOfferTitle: AdaptyUI.RichText?,
        footerBlock: AdaptyUI.OldFooterBlock?,
        closeButton: AdaptyUI.OldButton?,
        initialProducts: [ProductInfoModel],
        paywall: AdaptyPaywall,
        tagConverter: AdaptyUI.CustomTagConverter?
    ) {
        self.coverImage = coverImage
        self.coverImageHeightMultilpyer = coverImageHeightMultilpyer
        self.contentShape = contentShape
        self.titleRows = titleRows
        self.featuresBlock = featuresBlock
        self.productsBlock = productsBlock
        self.purchaseButton = purchaseButton
        self.purchaseButtonOfferTitle = purchaseButtonOfferTitle
        self.footerBlock = footerBlock
        self.closeButton = closeButton
        self.initialProducts = initialProducts
        self.paywall = paywall
        self.tagConverter = tagConverter
    }

    private weak var closeButtonComponentView: AdaptyButtonComponentView?
    private weak var activityIndicatorComponentView: AdaptyActivityIndicatorView?
    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var productsComponentView: ProductsComponentView?
    private weak var continueButtonComponentView: AdaptyButtonComponentView?
    private weak var scrollView: AdaptyBaseScrollView?

    var closeButtonView: AdaptyButtonComponentView? { closeButtonComponentView }
    var activityIndicator: AdaptyActivityIndicatorView? { activityIndicatorComponentView }
    var productsView: ProductsComponentView? { productsComponentView }
    var continueButton: AdaptyButtonComponentView? { continueButtonComponentView }

    private var onContinueCallback: (() -> Void)?
    private var onActionCallback: ((AdaptyUI.ButtonAction?) -> Void)?

    func addListeners(
        onContinue: @escaping () -> Void,
        onAction: @escaping (AdaptyUI.ButtonAction?) -> Void
    ) {
        onContinueCallback = onContinue
        onActionCallback = onAction
    }

    func continueButtonShowIntroCallToAction(_ show: Bool) {
        if show, let text = purchaseButtonOfferTitle {
            continueButtonComponentView?.updateContent(text)
        } else {
            continueButtonComponentView?.resetContent()
        }
    }

    func buildInterface(on view: UIView) throws {
        let verticalOverscroll = 64.0

        scrollViewDelegate.behaviours.append(
            AdaptyLimitOverscrollScrollBehaviour(maxOffsetTop: verticalOverscroll,
                                                 maxOffsetBottom: verticalOverscroll)
        )

        let backgroundView = AdaptyBackgroundComponentView(background: contentShape.background)
        layoutBackground(backgroundView, on: view)

        let imageView = UIImageView()
        imageView.setImage(coverImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        layoutCoverImageView(imageView,
                             on: view,
                             multiplier: coverImageHeightMultilpyer,
                             minHeight: nil)

        scrollViewDelegate.behaviours.append(
            AdaptyCoverImageScrollBehaviour(coverView: imageView)
        )

        let scrollView = AdaptyBaseScrollView()
        scrollView.delegate = scrollViewDelegate
        layoutScrollView(scrollView, on: view)
        self.scrollView = scrollView

        let contentView = AdaptyBaseContentView(
            layout: .basic(multiplier: coverImageHeightMultilpyer),
            shape: contentShape
        )

        layoutContentView(
            contentView,
            multiplier: coverImageHeightMultilpyer,
            topOverlap: contentShape.recommendedContentOverlap,
            bottomOverlap: verticalOverscroll,
            on: scrollView
        )

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: contentShape.recommendedContentOverlap,
                                                                 left: 20,
                                                                 bottom: 24 + verticalOverscroll,
                                                                 right: 20))

        if let titleRows = titleRows {
            try layoutTitleRows(titleRows, tagConverter, in: stackView)
        }

        if let featuresBlock = featuresBlock {
            try layoutFeaturesBlock(featuresBlock, tagConverter, in: stackView)
        }

        productsComponentView = try layoutProductsBlock(
            productsBlock,
            initialProducts: initialProducts, 
            paywall: paywall,
            tagConverter: tagConverter,
            in: stackView
        )

        let continueButtonPlaceholder = UIView()
        continueButtonPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        continueButtonPlaceholder.backgroundColor = .clear

        stackView.addArrangedSubview(continueButtonPlaceholder)
        stackView.addConstraint(
            continueButtonPlaceholder.heightAnchor.constraint(equalToConstant: 58.0)
        )

        let continueButtonView = AdaptyButtonComponentView(
            component: purchaseButton,
            tagConverter: tagConverter,
            addProgressView: true
        ) { [weak self] _ in
            self?.onContinueCallback?()
        }

        layoutContinueButton(continueButtonView,
                             placeholder: continueButtonPlaceholder,
                             on: view)

        continueButtonComponentView = continueButtonView
        contentViewComponentView = contentView

        if let footerBlock {
            let footerView = try AdaptyFooterComponentView(
                footerBlock: footerBlock,
                tagConverter: tagConverter,
                onTap: { [weak self] action in
                    self?.onActionCallback?(action)
                }
            )
            stackView.addArrangedSubview(footerView)
        }

        layoutTopGradientView(AdaptyGradientView(position: .top), on: view)
        layoutBottomGradientView(AdaptyGradientView(position: .bottom), on: view)

        if let closeButton = closeButton {
            let closeButtonView = AdaptyButtonComponentView(
                component: closeButton,
                tagConverter: tagConverter,
                contentViewMargins: .closeButtonDefaultMargin,
                onTap: { [weak self] _ in
                    self?.onActionCallback?(.close)
                }
            )

            layoutCloseButton(closeButtonView, on: view)
            closeButtonComponentView = closeButtonView
        }

        let progressView = AdaptyActivityIndicatorView(backgroundColor: .black.withAlphaComponent(0.6),
                                                       indicatorColor: .white)
        layoutProgressView(progressView, on: view)
        activityIndicatorComponentView = progressView
    }

    func viewDidLayoutSubviews(_ view: UIView) {
        contentViewComponentView?.updateSafeArea(view.safeAreaInsets)

        if let scrollView = scrollView {
            scrollViewDelegate.scrollViewDidScroll(scrollView)
        }
    }

    // MARK: - Layout

    private func layoutContentView(_ contentView: AdaptyBaseContentView,
                                   multiplier: CGFloat,
                                   topOverlap: CGFloat,
                                   bottomOverlap: CGFloat,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.backgroundColor = .clear

        scrollView.addSubview(spacerView)
        scrollView.addConstraints([
            spacerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            spacerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            spacerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor,
                                               multiplier: multiplier),
        ])

        scrollView.addConstraints([
            contentView.topAnchor.constraint(equalTo: spacerView.bottomAnchor,
                                             constant: -topOverlap),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: bottomOverlap),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
                                                multiplier: 1.0 - multiplier,
                                                constant: topOverlap + bottomOverlap + 32.0),
        ])
    }
}
