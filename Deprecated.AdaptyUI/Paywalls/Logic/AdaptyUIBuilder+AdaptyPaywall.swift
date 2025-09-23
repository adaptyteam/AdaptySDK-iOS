//
//  AdaptyUIBuilder+AdaptyPaywall.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Adapty
import AdaptyUIBuider
import Foundation

extension AdaptyPaywall: AdaptyPaywallModel {
    public var locale: String? { remoteConfig?.locale }
}
