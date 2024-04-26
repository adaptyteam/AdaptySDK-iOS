//
//  AdaptyPurchaseButtonShadeBehaviour.swift
//  
//
//  Created by Alexey Goncharov on 16.8.23..
//

import UIKit

struct AdaptyPurchaseButtonShadeBehaviour: AdaptyScrollViewBehaviour {
    let button: UIView
    let buttonPlaceholder: UIView
    let shadeView: UIView
    let baseView: UIView
    
    init(
        button: UIView,
        buttonPlaceholder: UIView,
        shadeView: UIView,
        baseView: UIView
    ) {
        self.button = button
        self.buttonPlaceholder = buttonPlaceholder
        self.shadeView = shadeView
        self.baseView = baseView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let buttonGlobalFrame = baseView.convert(button.frame, from: button.superview)
        let shadeGlobalFrame = baseView.convert(shadeView.frame, from: shadeView.superview)
        
        let intersection = buttonGlobalFrame.intersection(shadeGlobalFrame)
        shadeView.alpha = intersection.height / button.frame.height
//        print("## intersects: \(intersects)")
    }
}
