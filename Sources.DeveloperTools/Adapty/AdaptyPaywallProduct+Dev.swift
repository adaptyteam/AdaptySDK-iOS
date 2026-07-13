//
//  File.swift
//  Adapty
//
//  Created by Alex Goncharov on 20.05.2026.
//

import Adapty

extension AdaptyPaywallProduct: Identifiable {
    public var id: String { flowProductId ?? adaptyProductId }
}

