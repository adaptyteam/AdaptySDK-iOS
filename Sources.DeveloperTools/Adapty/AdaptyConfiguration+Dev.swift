//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 11/13/25.
//

import Adapty
import Foundation

public extension AdaptyConfiguration.Builder {
    @discardableResult
    func dev_with(
        mainBaseUrl: URL,
        adaptyAttributionBaseUrl: URL
    ) -> Self {
        with(backendBaseUrl: mainBaseUrl, for: .main)
            .with(backendBaseUrl: adaptyAttributionBaseUrl, for: .adaptyAttribution)
    }
}
