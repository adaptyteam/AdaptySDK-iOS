//
//  ProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

protocol ProductInfoView: UIView {
    init(product: ProductInfoModel, 
         info: AdaptyUI.ProductInfo,
         tagConverter: AdaptyUI.CustomTagConverter?) throws
}
