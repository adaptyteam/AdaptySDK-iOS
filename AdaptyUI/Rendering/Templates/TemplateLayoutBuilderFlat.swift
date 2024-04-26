//
//  TemplateLayoutBuilderFlat.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

class TemplateLayoutBuilderFlat: LayoutBuilder {
    private let background: AdaptyUI.Filling?
    private let contentShape: AdaptyUI.Decorator
    private let coverImage: AdaptyUI.Decorator
    private let coverImageHeightMultilpyer: CGFloat
    private let titleRows: AdaptyUI.RichText?
    private let featuresBlock: AdaptyUI.OldFeaturesBlock?
    private let productsBlock: AdaptyUI.OldProductsBlock
    private let purchaseButton: AdaptyUI.OldButton
    private let purchaseButtonOfferTitle: AdaptyUI.RichText?
    private let footerBlock: AdaptyUI.OldFooterBlock?
    private let closeButton: AdaptyUI.OldButton?
    private let initialProducts: [ProductInfoModel]
    private let paywall: AdaptyPaywall
    private let tagConverter: AdaptyUI.CustomTagConverter?

    private let scrollViewDelegate = AdaptyCompoundScrollViewDelegate()

    init(
        background: AdaptyUI.Filling?,
        contentShape: AdaptyUI.Decorator,
        coverImage: AdaptyUI.Decorator,
        coverImageHeightMultilpyer: CGFloat,
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
        self.background = background
        self.contentShape = contentShape
        self.coverImage = coverImage
        self.coverImageHeightMultilpyer = coverImageHeightMultilpyer
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

        let backgroundView = AdaptyBackgroundComponentView(background: background)
        layoutBackground(backgroundView, on: view)

        let scrollView = AdaptyBaseScrollView()
        scrollView.insetsLayoutMarginsFromSafeArea = false
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false

        scrollView.delegate = scrollViewDelegate
        layoutScrollView(scrollView, on: view)

        self.scrollView = scrollView

        let contentView = AdaptyBaseContentView(
            layout: .flat,
            shape: contentShape
        )

        layoutContentView(contentView,
                          topOverlap: verticalOverscroll,
                          bottomOverlap: verticalOverscroll,
                          on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: verticalOverscroll,
                                                                 left: 20,
                                                                 bottom: 24 + verticalOverscroll,
                                                                 right: 20))

        let imageView = AdaptyTitleImageComponentView(shape: coverImage)

        layoutTitleImageView(imageView,
                             on: stackView,
                             superView: view,
                             multiplier: coverImageHeightMultilpyer)

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

        if let footerBlock = footerBlock {
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

        let bottomShadeView = AdaptyGradientView(position: .bottom)
        layoutBottomGradientView(bottomShadeView, on: view)

        scrollViewDelegate.behaviours.append(
            AdaptyPurchaseButtonShadeBehaviour(
                button: continueButtonView,
                buttonPlaceholder: continueButtonPlaceholder,
                shadeView: bottomShadeView,
                baseView: view
            )
        )

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
                                   topOverlap: CGFloat,
                                   bottomOverlap: CGFloat,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

        scrollView.addConstraints([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -topOverlap),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: bottomOverlap),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
}
