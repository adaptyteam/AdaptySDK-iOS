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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCustomerUserIdLabel()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    func updateCustomerUserIdLabel() {
        customerUserIdLabel.text = "Customer User Id: \(Adapty.customerUserId ?? "none")"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func logOutButtonAction(_ sender: Any) {
        Adapty.logout()
        
        updateCustomerUserIdLabel()
        infoLabel.text = "User logged out successfully"
    }
    
    @IBAction func updateProfileButtonAction(_ sender: Any) {
        guard let customerUserId = customerUserIdTextField.text else {
            return
        }
        
        setLoader(true)
        Adapty.updateProfile(customerUserId: customerUserId) { (error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to update user: \(error)"
            } else {
                self.infoLabel.text = "User updated successfully"
            }
            
            self.updateCustomerUserIdLabel()
        }
    }
    
    @IBAction func updateAdjustAttributionButtonAction(_ sender: Any) {
        setLoader(true)
        let attribution = ADJAttribution(jsonDict: ["trackerToken": "test_trackerToken", "trackerName": "test_trackerName", "network": "test_network", "campaign": "test_campaign", "adgroup": "test_adgroup", "creative": "test_creative", "clickLabel": "test_clickLabel"], adid: "test_adid")
        Adapty.updateAdjustAttribution(attribution) { (error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to update attribution: \(error)"
            } else {
                self.infoLabel.text = "Attribution updated successfully"
            }
        }
    }
    
    @IBAction func validateReceiptButtonAction(_ sender: Any) {
        let receipt = "ewoJInNpZ25hdHVyZSIgPSAiQTU5WU03TDRrSEVUYTE3dmZwdG15RHF4dW5sK3EzTTRTL2dPZlRrRFhreDRtWEtCWm1DNEJlTXd1OGFMbHAvbVRuR3lZbVRzQ1RaTkl5Qzg5ZENreG0xUDdUV0ZkTGU3c2VQclh5bVA3VGdVRkJ1ZHZtZ3FLbmROTzdZSlN0Tk56WVFSZWczZkg1Y2ppYWU1YW13KzQzWWtUR0o3KzFzYllxZG53bi9PYnhMdTZZYVM4L0g0SUZuNi9qbUtBdmc2cTdxY0NLQ3B4UDRUSW9GMlN3Wk5TREFzV3Y5KzJxS241L0x6bVY0NUtuWGticmpEK203SVZJSUhJQVBrNmNtVGtaMGhEaEpQR0dTa2JWUmNMd2ZlMVZ3alZyZnZKb3daZ3ZybHNpK3ZaeVRKNFkrWUNqQ0diSmVQbXF1WTZDWGhUS2EySXpqdzRzRDBydVVUZkcwYUtiOEFBQVdBTUlJRmZEQ0NCR1NnQXdJQkFnSUlEdXRYaCtlZUNZMHdEUVlKS29aSWh2Y05BUUVGQlFBd2daWXhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1Td3dLZ1lEVlFRTERDTkJjSEJzWlNCWGIzSnNaSGRwWkdVZ1JHVjJaV3h2Y0dWeUlGSmxiR0YwYVc5dWN6RkVNRUlHQTFVRUF3dzdRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTWdRMlZ5ZEdsbWFXTmhkR2x2YmlCQmRYUm9iM0pwZEhrd0hoY05NVFV4TVRFek1ESXhOVEE1V2hjTk1qTXdNakEzTWpFME9EUTNXakNCaVRFM01EVUdBMVVFQXd3dVRXRmpJRUZ3Y0NCVGRHOXlaU0JoYm1RZ2FWUjFibVZ6SUZOMGIzSmxJRkpsWTJWcGNIUWdVMmxuYm1sdVp6RXNNQ29HQTFVRUN3d2pRWEJ3YkdVZ1YyOXliR1IzYVdSbElFUmxkbVZzYjNCbGNpQlNaV3hoZEdsdmJuTXhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBcGMrQi9TV2lnVnZXaCswajJqTWNqdUlqd0tYRUpzczl4cC9zU2cxVmh2K2tBdGVYeWpsVWJYMS9zbFFZbmNRc1VuR09aSHVDem9tNlNkWUk1YlNJY2M4L1cwWXV4c1FkdUFPcFdLSUVQaUY0MWR1MzBJNFNqWU5NV3lwb041UEM4cjBleE5LaERFcFlVcXNTNCszZEg1Z1ZrRFV0d3N3U3lvMUlnZmRZZUZScjZJd3hOaDlLQmd4SFZQTTNrTGl5a29sOVg2U0ZTdUhBbk9DNnBMdUNsMlAwSzVQQi9UNXZ5c0gxUEttUFVockFKUXAyRHQ3K21mNy93bXYxVzE2c2MxRkpDRmFKekVPUXpJNkJBdENnbDdaY3NhRnBhWWVRRUdnbUpqbTRIUkJ6c0FwZHhYUFEzM1k3MkMzWmlCN2o3QWZQNG83UTAvb21WWUh2NGdOSkl3SURBUUFCbzRJQjF6Q0NBZE13UHdZSUt3WUJCUVVIQVFFRU16QXhNQzhHQ0NzR0FRVUZCekFCaGlOb2RIUndPaTh2YjJOemNDNWhjSEJzWlM1amIyMHZiMk56Y0RBekxYZDNaSEl3TkRBZEJnTlZIUTRFRmdRVWthU2MvTVIydDUrZ2l2Uk45WTgyWGUwckJJVXdEQVlEVlIwVEFRSC9CQUl3QURBZkJnTlZIU01FR0RBV2dCU0lKeGNKcWJZWVlJdnM2N3IyUjFuRlVsU2p0ekNDQVI0R0ExVWRJQVNDQVJVd2dnRVJNSUlCRFFZS0tvWklodmRqWkFVR0FUQ0IvakNCd3dZSUt3WUJCUVVIQWdJd2diWU1nYk5TWld4cFlXNWpaU0J2YmlCMGFHbHpJR05sY25ScFptbGpZWFJsSUdKNUlHRnVlU0J3WVhKMGVTQmhjM04xYldWeklHRmpZMlZ3ZEdGdVkyVWdiMllnZEdobElIUm9aVzRnWVhCd2JHbGpZV0pzWlNCemRHRnVaR0Z5WkNCMFpYSnRjeUJoYm1RZ1kyOXVaR2wwYVc5dWN5QnZaaUIxYzJVc0lHTmxjblJwWm1sallYUmxJSEJ2YkdsamVTQmhibVFnWTJWeWRHbG1hV05oZEdsdmJpQndjbUZqZEdsalpTQnpkR0YwWlcxbGJuUnpMakEyQmdnckJnRUZCUWNDQVJZcWFIUjBjRG92TDNkM2R5NWhjSEJzWlM1amIyMHZZMlZ5ZEdsbWFXTmhkR1ZoZFhSb2IzSnBkSGt2TUE0R0ExVWREd0VCL3dRRUF3SUhnREFRQmdvcWhraUc5Mk5rQmdzQkJBSUZBREFOQmdrcWhraUc5dzBCQVFVRkFBT0NBUUVBRGFZYjB5NDk0MXNyQjI1Q2xtelQ2SXhETUlKZjRGelJqYjY5RDcwYS9DV1MyNHlGdzRCWjMrUGkxeTRGRkt3TjI3YTQvdncxTG56THJSZHJqbjhmNUhlNXNXZVZ0Qk5lcGhtR2R2aGFJSlhuWTR3UGMvem83Y1lmcnBuNFpVaGNvT0FvT3NBUU55MjVvQVE1SDNPNXlBWDk4dDUvR2lvcWJpc0IvS0FnWE5ucmZTZW1NL2oxbU9DK1JOdXhUR2Y4YmdwUHllSUdxTktYODZlT2ExR2lXb1IxWmRFV0JHTGp3Vi8xQ0tuUGFObVNBTW5CakxQNGpRQmt1bGhnd0h5dmozWEthYmxiS3RZZGFHNllRdlZNcHpjWm04dzdISG9aUS9PamJiOUlZQVlNTnBJcjdONFl0UkhhTFNQUWp2eWdhWndYRzU2QWV6bEhSVEJoTDhjVHFBPT0iOwoJInB1cmNoYXNlLWluZm8iID0gImV3b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGNITjBJaUE5SUNJeU1ERTVMVEV3TFRJeUlERXpPakEwT2pNeUlFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKemRXSnpZM0pwY0hScGIyNHRaM0p2ZFhBdGFXUmxiblJwWm1sbGNpSWdQU0FpTWpBek9URXlPREFpT3dvSkluVnVhWEYxWlMxMlpXNWtiM0l0YVdSbGJuUnBabWxsY2lJZ1BTQWlNekpDT1VRNU56UXROVFE0TlMwME1qUTFMVUpGTkVVdFF6YzRSRVEzTXpBMFF6YzRJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhOVGN4TnpjME5qY3lNREF3SWpzS0NTSmxlSEJwY21WekxXUmhkR1V0Wm05eWJXRjBkR1ZrSWlBOUlDSXlNREU1TFRFd0xUSTVJREl3T2pBME9qTXlJRVYwWXk5SFRWUWlPd29KSW1sekxXbHVMV2x1ZEhKdkxXOW1abVZ5TFhCbGNtbHZaQ0lnUFNBaVptRnNjMlVpT3dvSkluQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakUxTnpFM056UTJOekl3TURBaU93b0pJbVY0Y0dseVpYTXRaR0YwWlMxbWIzSnRZWFIwWldRdGNITjBJaUE5SUNJeU1ERTVMVEV3TFRJNUlERXpPakEwT2pNeUlFRnRaWEpwWTJFdlRHOXpYMEZ1WjJWc1pYTWlPd29KSW1sekxYUnlhV0ZzTFhCbGNtbHZaQ0lnUFNBaWRISjFaU0k3Q2draWFYUmxiUzFwWkNJZ1BTQWlNVEl5TnpReE1UUXpNeUk3Q2draWRXNXBjWFZsTFdsa1pXNTBhV1pwWlhJaUlEMGdJakF3TURBNE1ESXdMVEF3TVRNeU5ERkRNa1UwTWpBd01rVWlPd29KSW05eWFXZHBibUZzTFhSeVlXNXpZV04wYVc5dUxXbGtJaUE5SUNJek5UQXdNREExTXpVeU1UTTVOemNpT3dvSkltVjRjR2x5WlhNdFpHRjBaU0lnUFNBaU1UVTNNak0zT1RRM01qQXdNQ0k3Q2draVlYQndMV2wwWlcwdGFXUWlJRDBnSWpVNE1qWTNNVFEzTnlJN0Nna2lkSEpoYm5OaFkzUnBiMjR0YVdRaUlEMGdJak0xTURBd01EVXpOVEl4TXprM055STdDZ2tpWW5aeWN5SWdQU0FpTXlJN0Nna2lkMlZpTFc5eVpHVnlMV3hwYm1VdGFYUmxiUzFwWkNJZ1BTQWlNelV3TURBd01UZzRNelUwTWpBNUlqc0tDU0oyWlhKemFXOXVMV1Y0ZEdWeWJtRnNMV2xrWlc1MGFXWnBaWElpSUQwZ0lqZ3pNRGc0TURFNU5TSTdDZ2tpWW1sa0lpQTlJQ0pqYjIwdVpXRnplVEV3TG5KMUxXVnVJanNLQ1NKd2NtOWtkV04wTFdsa0lpQTlJQ0l4WDIxdmJuUm9YM04xWW5OamNtbHdkR2x2Ymw5UVVrVk5TVlZOWDNSeWFXRnNYeklpT3dvSkluQjFjbU5vWVhObExXUmhkR1VpSUQwZ0lqSXdNVGt0TVRBdE1qSWdNakE2TURRNk16SWdSWFJqTDBkTlZDSTdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTMXdjM1FpSUQwZ0lqSXdNVGt0TVRBdE1qSWdNVE02TURRNk16SWdRVzFsY21sallTOU1iM05mUVc1blpXeGxjeUk3Q2draWIzSnBaMmx1WVd3dGNIVnlZMmhoYzJVdFpHRjBaU0lnUFNBaU1qQXhPUzB4TUMweU1pQXlNRG93TkRvek1pQkZkR012UjAxVUlqc0tmUT09IjsKCSJwb2QiID0gIjM1IjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0="
        
        setLoader(true)
        Adapty.validateReceipt(receipt) { (response, error) in
            self.setLoader(false)
            if let error = error {
                self.infoLabel.text = "Failed to validate receipt: \(error)"
            } else if let response = response {
                self.infoLabel.text = "Receipt validated successfully: \n\(response)"
            }
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

