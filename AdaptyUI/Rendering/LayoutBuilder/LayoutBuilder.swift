//
//  LayoutBuilder.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

protocol LayoutBuilder {
    var closeButtonView: AdaptyButtonComponentView? { get }
    var activityIndicator: AdaptyActivityIndicatorView? { get }
    var productsView: ProductsComponentView? { get }
    var continueButton: AdaptyButtonComponentView? { get }
    
    func buildInterface(on view: UIView) throws
    func viewDidLayoutSubviews(_ view: UIView)
    
    func continueButtonShowIntroCallToAction(_ show: Bool)
    
    func addListeners(
        onContinue: @escaping () -> Void,
        onAction: @escaping (AdaptyUI.ButtonAction?) -> Void
    )
}
