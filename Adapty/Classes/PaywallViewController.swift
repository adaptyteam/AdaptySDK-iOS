//
//  PaywallViewController.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/05/2020.
//

#if os(iOS)
import UIKit
import WebKit

@objc public protocol AdaptyVisualPaywallDelegate: class {
    
    func didPurchase(product: ProductModel, purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, paywall: PaywallViewController)
    func didFailPurchase(product: ProductModel, error: AdaptyError, paywall: PaywallViewController)
    func didCancel(paywall: PaywallViewController)
    func didRestore(purchaserInfo: PurchaserInfoModel?, receipt: String?, appleValidationResult: Parameters?, error: AdaptyError?, paywall: PaywallViewController)
}

@objc public class PaywallViewController: UIViewController {
    
    var paywall: PaywallModel!
    weak var delegate: AdaptyVisualPaywallDelegate?
    
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
        
        fulfillDataFromPaywall()
        configureLoader()
        
        logKinesisEvent(.paywallShowed)
    }
    
    internal func close() {
        dismiss(animated: true)
    }
    
    private func cancel() {
        logKinesisEvent(.paywallClosed)
        delegate?.didCancel(paywall: self)
    }
    
    private func fulfillDataFromPaywall() {
        var htmlString = paywall.visualPaywall ?? ""
        let placeholder = ""
        
        htmlString = htmlString.replacingOccurrences(of: "%adapty_paywall_padding_top%", with: "\(UIApplication.topOffset)")
        htmlString = htmlString.replacingOccurrences(of: "%adapty_paywall_padding_bottom%", with: "\(UIApplication.bottomOffset)")
        
        paywall.products.forEach { (product) in
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
        logKinesisEvent(.purchaseStarted, vendorProductId: product.vendorProductId)
        
        setLoaderVisible(true, animated: true)
        Adapty.makePurchase(product: product, offerId: product.promotionalOfferId) { (purchaserInfo, receipt, appleValidationResult, _, error) in
            self.setLoaderVisible(false, animated: true)
            
            if let error = error {
                if error.adaptyErrorCode == .paymentCancelled {
                    self.logKinesisEvent(.purchaseCancelled, vendorProductId: product.vendorProductId)
                }
                
                self.delegate?.didFailPurchase(product: product, error: error, paywall: self)
            } else {
                self.delegate?.didPurchase(product: product, purchaserInfo: purchaserInfo, receipt: receipt, appleValidationResult: appleValidationResult, paywall: self)
            }
        }
    }
    
    private func restorePurchases() {
        logKinesisEvent(.purchaseRestore)
        
        setLoaderVisible(true, animated: true)
        Adapty.restorePurchases { purchaserInfo, receipt, appleValidationResult, error in
            self.setLoaderVisible(false, animated: true)
            
            self.delegate?.didRestore(purchaserInfo: purchaserInfo, receipt: receipt, appleValidationResult: appleValidationResult, error: error, paywall: self)
        }
    }
    
    private func logKinesisEvent(_ name: EventType, vendorProductId: String? = nil) {
        var params = ["is_promo": paywall.isPromo.description, "variation_id": paywall.variationId]
        if let vendorProductId = vendorProductId {
            params["vendor_product_id"] = vendorProductId
        }
        kinesisManager.trackEvent(name, params: params)
    }

}

extension PaywallViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
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
            cancel()
        }
        
        if url == "adapty://action/restore_purchases" {
            restorePurchases()
        }
        
        paywall.products.forEach { (product) in
            if url == "adapty://in_app/\(product.vendorProductId)" {
                self.logKinesisEvent(.inAppClicked, vendorProductId: product.vendorProductId)
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

#endif
