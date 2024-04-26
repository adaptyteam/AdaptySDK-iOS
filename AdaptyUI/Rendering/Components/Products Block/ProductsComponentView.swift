//
//  ProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

protocol ProductsComponentView: UIView {
    var onProductSelected: ((ProductInfoModel) -> Void)? { get set }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) throws
    func updateSelectedState(_ productId: String)
}
