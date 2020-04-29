//
//  ViewController.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import UIKit
import Adapty
import Adjust

class ViewController: UIViewController {

    @IBOutlet weak var customerUserIdLabel: UILabel!
    @IBOutlet weak var customerUserIdTextField: UITextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var currentPromoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCustomerUserIdLabel()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "PromoUpdated"), object: nil, queue: OperationQueue.main) { (notification) in
            self.updateCurrentPromoLabel(from: notification.object)
        }
    }
    
    func updateCustomerUserIdLabel() {
        customerUserIdLabel.text = "Customer User Id: \(Adapty.customerUserId ?? "none")"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func logOutButtonAction(_ sender: Any) {
        Adapty.logout { (error) in
            if error == nil {
                self.updateCustomerUserIdLabel()
                self.infoLabel.text = "User logged out successfully"
            }
        }
    }
    
    @IBAction func updateProfileButtonAction(_ sender: Any) {
        guard let customerUserId = customerUserIdTextField.text else {
            return
        }
        
        setLoader(true)
        Adapty.identify(customerUserId) { (error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to identify user: \(error)"
            } else {
                self.infoLabel.text = "Successfully identified user"
            }
            
            self.updateCustomerUserIdLabel()
        }
    }
    
    @IBAction func updateAttributionButtonAction(_ sender: Any) {
        setLoader(true)
        let attribution = ["trackerToken": "test_trackerToken", "trackerName": "test_trackerName", "network": "test_network", "campaign": "test_campaign", "adgroup": "test_adgroup", "creative": "test_creative", "clickLabel": "test_clickLabel", "adid": "test_adid"]
        Adapty.updateAttribution(attribution, source: .adjust) { (error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to update attribution: \(error)"
            } else {
                self.infoLabel.text = "Attribution updated successfully"
            }
        }
    }
    
    @IBAction func validateReceiptButtonAction(_ sender: Any) {
        let receipt = "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"
        
        setLoader(true)
        Adapty.validateReceipt(receipt) { (purchaserInfo, appleValidationResult, error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to validate receipt: \(error)"
            } else if let appleValidationResult = appleValidationResult {
                self.infoLabel.text = "Receipt validated successfully: \n\(appleValidationResult)"
            }
        }
    }
    
    @IBAction func getPurchaserInfoButtonAction(_ sender: Any) {
        setLoader(true)
        Adapty.getPurchaserInfo { (purchaserInfo, state, error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to get purchaser info: \(error)"
            }
            if let purchaserInfo = purchaserInfo {
                self.infoLabel.text =
                """
                Paid access standart is active: \(purchaserInfo.paidAccessLevels["standart"]?.isActive ?? false)\n
                paidAccessLevels:\n\(purchaserInfo.paidAccessLevels)
                subscriptions:\n\(purchaserInfo.subscriptions)
                Non subscriptions:\n\(purchaserInfo.nonSubscriptions)
                """
            }
        }
    }
    
    @IBAction func getPromoButtonAction(_ sender: Any) {
        setLoader(true)
        Adapty.getPromo { (promo, error) in
            self.setLoader(false)
            self.updateCurrentPromoLabel(from: promo)
            if let error = error {
                self.infoLabel.text = "Failed to get promo: \(error)"
                return
            }
            if promo == nil {
                self.infoLabel.text = "There is no active/available promo"
                return
            }
            if let promo = promo {
                self.infoLabel.text = "promoType: \(promo.promoType), variationId: \(promo.variationId), container name: \(promo.container?.developerId ?? "none"), container: \(String(describing: promo.container))"
            }
        }
    }
    
    func updateCurrentPromoLabel(from promo: Any?) {
        if let promo = promo as? PromoModel, let developerId = promo.container?.developerId {
            currentPromoLabel.text = "Current promo: \(developerId)"
        } else {
            currentPromoLabel.text = "Current promo: none"
        }
    }
    
    func setLoader(_ visible: Bool) {
        if visible {
            activityIndicatorView.startAnimating()
            infoLabel.isHidden = true
        } else {
            activityIndicatorView.stopAnimating()
            infoLabel.isHidden = false
        }
    }
    
}

