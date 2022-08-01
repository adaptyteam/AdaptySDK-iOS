//
//  ShowcasePaywallViewController.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 17.12.2021.
//  Copyright © 2021 Adapty. All rights reserved.
//

import UIKit
import Adapty

class ShowcasePaywallViewController: UIViewController {
    
    var paywall: PaywallModel
    private var activeProduct: ProductModel?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var featuresStackView: UIStackView!
    @IBOutlet weak var featuresStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstPlanView: PlanView! {
        didSet {
            firstPlanView.delegate = self
        }
    }
    @IBOutlet weak var secondPlanView: PlanView! {
        didSet {
            secondPlanView.delegate = self
        }
    }
    @IBOutlet weak var restorePurchasesLabel: UILabel! {
        didSet {
            restorePurchasesLabel.isUserInteractionEnabled = true
            restorePurchasesLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restorePurchasesAction)))
        }
    }
    @IBOutlet weak var subscribeButton: UIButton! {
        didSet {
            subscribeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }
    @IBOutlet weak var loaderView: UIView!
    
    init(paywall: PaywallModel) {
        self.paywall = paywall
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        // example of such payload is in remote_config_example.json file
        let customPayload = paywall.customPayload
        
        if let headerImageURL = customPayload?.headerImageURL {
            downloadImage(from: headerImageURL)
        }
        if let header = customPayload?.header {
            titleLabel.text = header
        }
        customPayload?.features?.forEach({ feature in
            self.featuresStackView.addArrangedSubview(self.createFeatureView(for: feature))
        })
        featuresStackViewHeightConstraint.constant = CGFloat((customPayload?.features?.count ?? 0)) * 20
        if let product = paywall.products[safe: 0] {
            firstPlanView.product = product
            if product.subscriptionPeriod?.unit == .year {
                firstPlanView.selectPlan()
            }
        }
        if let product = paywall.products[safe: 1] {
            secondPlanView.product = product
            if product.subscriptionPeriod?.unit == .year {
                secondPlanView.selectPlan()
            }
        }
    }
    
    @IBAction private func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func restorePurchasesAction() {
        setLoader(visible: true, animated: true)
        
        Adapty.restorePurchases { purchaserInfo, receipt, appleValidationResult, error in
            self.setLoader(visible: false, animated: true)
            
            self.showResultAlert(with: error == nil ? "Successful restore" : error?.localizedDescription)
        }
    }
    
    @IBAction private func subscribeButtonAction(_ sender: Any) {
        guard let product = activeProduct else {
            return
        }
        
        setLoader(visible: true, animated: true)
        
        Adapty.makePurchase(product: product) { purchaserInfo, receipt, appleValidationResult, product, error in
            self.setLoader(visible: false, animated: true)
            
            self.showResultAlert(with: error == nil ? "Successful purchase" : error?.localizedDescription)
        }
    }
    
    private func setLoader(visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.loaderView.alpha = visible ? 1 : 0
        }
    }
    
    private func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func createFeatureView(for feature: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 275, height: 20))
        
        let imageVIew = UIImageView(image: UIImage(named: "checkbox-icon"))
        imageVIew.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        view.addSubview(imageVIew)
        
        let label = UILabel(frame: CGRect(x: 25, y: 0, width: 250, height: 20))
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = feature
        view.addSubview(label)
        
        return view
    }
    
}

extension ShowcasePaywallViewController: PlanViewDelegate {
    
    func didSelect(product: ProductModel?) {
        firstPlanView.isActive = firstPlanView.product == product
        secondPlanView.isActive = secondPlanView.product == product
        
        activeProduct = product
    }
    
}

protocol PlanViewDelegate: AnyObject {
    
    func didSelect(product: ProductModel?)
    
}

class PlanView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    var isActive: Bool = false {
        didSet {
            if isActive {
                backgroundColor = UIColor(rgb: 0x5136B5)
                priceLabel.textColor = .white
                pricePerPeriodLabel.textColor = .white
                introPeriodLabel.textColor = .white
            } else {
                backgroundColor = UIColor(rgb: 0xE7E6FC)
                priceLabel.textColor = .black
                pricePerPeriodLabel.textColor = .black
                introPeriodLabel.textColor = .black
            }
            
        }
    }
    
    var product: ProductModel? {
        didSet {
            guard let product = product else {
                return
            }
            
            var periodString = ""
            switch product.subscriptionPeriod?.unit {
            case .day:
                periodString = "Daily"
            case .week:
                periodString = "Weekly"
            case .month:
                periodString = "Monthly"
            case .year:
                periodString = "Annual"
            default:
                break
            }
            
            priceLabel.text = "\(product.localizedPrice ?? "") \(periodString)"
            pricePerPeriodLabel.text = ""
            introPeriodLabel.text = product.localizedTitle
            bestValueView.isHidden = product.subscriptionPeriod?.unit != .year
        }
    }
    
    weak var delegate: PlanViewDelegate?
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pricePerPeriodLabel: UILabel!
    @IBOutlet weak var introPeriodLabel: UILabel!
    @IBOutlet weak var bestValueView: UILabel!
    
    private func configure() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPlan)))
    }
    
    @objc func selectPlan() {
        delegate?.didSelect(product: product)
    }
    
}

extension Parameters {
    
    var headerImageURL: URL? {
        if let url = self["header_image"] as? String {
            return URL(string: url)
        }
        return nil
    }
    
    var header: String? {
        return self["header"] as? String
    }
    
    var features: [String]? {
        return self["features"] as? [String]
    }
    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}

extension Array {
    
    subscript (safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index), let newValue = newValue {
                self[index] = newValue
            }
        }
    }
    
}

extension UIViewController {
    
    func showResultAlert(with message: String?) {
        let ac = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
}
