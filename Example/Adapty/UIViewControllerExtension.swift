//
//  UIViewControllerExtension.swift
//  Adapty_Example
//
//  Created by Andrey Kyashkin on 03/01/2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(for error: Error?) {
        guard let error = error else {
            return
        }
        
        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func setUI(enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
    
}
