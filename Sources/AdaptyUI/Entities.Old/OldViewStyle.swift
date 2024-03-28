//
//  OldViewStyle.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI {
    public struct OldViewStyle {
        public let featureBlock: AdaptyUI.OldFeaturesBlock?
        public let productBlock: AdaptyUI.OldProductsBlock
        public let footerBlock: AdaptyUI.OldFooterBlock?
        public let items: [String: AdaptyUI.OldViewItem]
    }
}
