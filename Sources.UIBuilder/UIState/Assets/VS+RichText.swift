//
//  VS+RichText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.01.2026.
//

import Foundation

extension VS {
    @inlinable
    func richText(_ stringId: String) throws(VS.Error) -> VC.RichText? {
        configuration.strings[stringId]
    }
}
