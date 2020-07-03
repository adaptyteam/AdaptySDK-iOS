//
//  PaywallViewController.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/05/2020.
//

import UIKit
import WebKit

@objc public protocol AdaptyPaywallDelegate: class {
    
    func didPurchase(product: ProductModel, purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, paywall: PaywallViewController)
    func didFailPurchase(product: ProductModel, error: Error, paywall: PaywallViewController)
    func didClose(paywall: PaywallViewController)
    
}

@objc public class PaywallViewController: UIViewController {
    
    var container: PurchaseContainerModel!
    weak var delegate: AdaptyPaywallDelegate?
    
    private var webView: WebView!
    private var loaderView: UIView!
    private var loaderActivityIndicatorView: UIActivityIndicatorView!
    private lazy var kinesisManager: KinesisManager = {
        return KinesisManager.shared
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        webView = WebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.white
        view.addSubview(webView)
        
        fulfillDataFromContainer()
        configureLoader()
        
        logKinesisEvent(.paywallShowed)
    }
    
    @objc public func close() {
        logKinesisEvent(.paywallClosed)
        dismiss(animated: true)
        delegate?.didClose(paywall: self)
    }
    
    private func fulfillDataFromContainer() {
        var htmlString = container.visualPaywall
        let placeholder = ""
        
        container.products.forEach { (product) in
            htmlString = htmlString.replacingOccurrences(of: "%adapty_title_\(product.vendorProductId)%", with: product.localizedTitle)
            htmlString = htmlString.replacingOccurrences(of: "%adapty_price_\(product.vendorProductId)%", with: (product.localizedPrice ?? placeholder))
            htmlString = htmlString.replacingOccurrences(of: "%adapty_duration_\(product.vendorProductId)%", with: (product.localizedSubscriptionPeriod ?? placeholder))
            
            
            htmlString = htmlString.replacingOccurrences(of: "%adapty_introductory_price_\(product.vendorProductId)%", with: (product.introductoryDiscount?.localizedPrice ?? placeholder))
            htmlString = htmlString.replacingOccurrences(of: "%adapty_introductory_duration_\(product.vendorProductId)%", with: (product.introductoryDiscount?.localizedSubscriptionPeriod ?? placeholder))
            
            product.discounts.forEach { (discount) in
                if let identifier = discount.identifier {
                    htmlString = htmlString.replacingOccurrences(of: "%adapty_promotional_price_\(product.vendorProductId)_\(identifier)%", with: (discount.localizedPrice ?? placeholder))
                    htmlString = htmlString.replacingOccurrences(of: "%adapty_promotional_duration_\(product.vendorProductId)_\(identifier)%", with: (discount.localizedSubscriptionPeriod ?? placeholder))
                    htmlString = htmlString.replacingOccurrences(of: "%adapty_promotional_periods_\(product.vendorProductId)_\(identifier)%", with: (discount.localizedNumberOfPeriods ?? ""))
                }
            }
        }
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    private func configureLoader() {
        loaderView = UIView(frame: view.frame)
        loaderView.backgroundColor = UIColor(white: 0, alpha: 0.65)
        view.addSubview(loaderView)
        
        loaderActivityIndicatorView = UIActivityIndicatorView(style: .white)
        loaderActivityIndicatorView.startAnimating()
        loaderView.addSubview(loaderActivityIndicatorView)
        loaderActivityIndicatorView.center = loaderView.center
        
        setLoaderVisible(false, animated: false)
    }
    
    private func setLoaderVisible(_ visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.loaderView.alpha = visible ? 1 : 0
        }
    }
    
    private func buyProduct(_ product: ProductModel) {
        self.logKinesisEvent(.purchaseStarted, vendorProductId: product.vendorProductId)
        
        setLoaderVisible(true, animated: true)
        Adapty.makePurchase(product: product, offerId: product.promotionalOfferId) { (purchaserInfo, receipt, appleValidationResult, _, error) in
            self.setLoaderVisible(false, animated: true)
            
            if let error = error {
                if (error as? IAPManagerError) == IAPManagerError.paymentWasCancelled {
                    self.logKinesisEvent(.purchaseCancelled, vendorProductId: product.vendorProductId)
                }
                
                self.delegate?.didFailPurchase(product: product, error: error, paywall: self)
            } else {
                self.delegate?.didPurchase(product: product, purchaserInfo: purchaserInfo, receipt: receipt, appleValidationResult: appleValidationResult, paywall: self)
            }
        }
    }
    
    private func logKinesisEvent(_ name: EventType, vendorProductId: String? = nil) {
        var params = ["is_promo": container.isPromo.description, "variation_id": container.variationId]
        if let vendorProductId = vendorProductId {
            params["vendor_product_id"] = vendorProductId
        }
        kinesisManager.trackEvent(name, params: params)
    }

}

extension PaywallViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.absoluteString == "about:blank" {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.cancel)
        
        guard let URL = navigationAction.request.url else {
            return
        }
        
        let url = URL.absoluteString
        
        guard url.contains("adapty://") else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL)
            } else {
                UIApplication.shared.openURL(URL)
            }
            return
        }
        
        if url == "adapty://action/close_paywall" {
            close()
        }
        
        container.products.forEach { (product) in
            if url == "adapty://in_app/\(product.vendorProductId)" {
                logKinesisEvent(.inAppClicked, vendorProductId: product.vendorProductId)
            }
            
            if url == "adapty://action/subscribe/\(product.vendorProductId)" {
                self.buyProduct(product)
                return
            }
        }
    }
    
}

class WebView: WKWebView {
    
    override var safeAreaInsets: UIEdgeInsets {
        .zero
    }
    
}

