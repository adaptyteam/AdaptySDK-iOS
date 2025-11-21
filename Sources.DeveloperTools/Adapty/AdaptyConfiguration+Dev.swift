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
        uaBaseUrl: URL
    ) -> Self {
        with(backendBaseUrl: mainBaseUrl, for: .main)
            .with(backendBaseUrl: uaBaseUrl, for: .ua)
    }
}
