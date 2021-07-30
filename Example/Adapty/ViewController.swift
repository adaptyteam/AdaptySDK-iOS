//
//  ViewController.swift
//  Adapty
//
//  Created by sugarofff@yandex.ru on 11/06/2019.
//  Copyright (c) 2019 sugarofff@yandex.ru. All rights reserved.
//

import UIKit
import Adapty

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
    
    @IBAction func updateProfileAttributesButtonAction(_ sender: Any) {
        setLoader(true)
        var params =
            ProfileParameterBuilder().withEmail("email@email.com").withPhoneNumber("+78888888888").withFacebookUserId("facebookUserId-test").withAmplitudeUserId("amplitudeUserId-test").withAmplitudeDeviceId("amplitudeDeviceId-test").withMixpanelUserId("mixpanelUserId-test").withAppmetricaProfileId("appmetricaProfileId-test").withAppmetricaDeviceId("appmetricaDeviceId-test").withFirstName("First Name").withLastName("Last Name").withGender(.other).withBirthday(Date()).withCustomAttributes(["key1": "value1", "key2": "value2"]).withFacebookAnonymousId("facebookAnonymousId-test")
        if #available(iOS 14, macOS 11.0, *) {
            params = params.withAppTrackingTransparencyStatus(.authorized)
        }
        Adapty.updateProfile(params: params) { (error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to update user: \(error)"
            } else {
                self.infoLabel.text = "Successfully updated user"
            }
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
    
    @IBAction func getPurchaserInfoButtonAction(_ sender: Any) {
        setLoader(true)
        Adapty.getPurchaserInfo { (purchaserInfo, error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to get purchaser info: \(error)"
            }
            if let purchaserInfo = purchaserInfo {
                self.infoLabel.text =
                """
                Paid access standart is active: \(purchaserInfo.accessLevels["standart"]?.isActive ?? false)\n
                accessLevels:\n\(purchaserInfo.accessLevels)
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
                self.infoLabel.text = "promoType: \(promo.promoType), variationId: \(promo.variationId), paywall name: \(promo.paywall?.developerId ?? "none"), paywall: \(String(describing: promo.paywall))"
            }
        }
    }
    
    func updateCurrentPromoLabel(from promo: Any?) {
        if let promo = promo as? PromoModel, let developerId = promo.paywall?.developerId {
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

