//
//  AdaptyUIBuilder+URL.swift
//  AdaptyUIBuilder
//

import Foundation

package extension URL {
    /// `SFSafariViewController` (the in-app browser) supports only `http`/`https`.
    /// Any other scheme (`mailto`, `tel`, `sms`, a missing scheme, …) makes its
    /// initializer raise an uncatchable `NSInvalidArgumentException`, so every
    /// in-app-browser call site must pre-validate the scheme against this.
    var isWebLink: Bool {
        switch scheme?.lowercased() {
        case "http", "https": true
        default: false
        }
    }
}
