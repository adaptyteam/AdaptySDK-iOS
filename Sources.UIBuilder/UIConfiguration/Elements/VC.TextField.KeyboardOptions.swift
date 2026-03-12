//
//  VC.TextField.KeyboardOptions.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC.TextField {
    struct KeyboardOptions: Hashable {
        let keyboardType: String?
        let contentType: String?
        let autocapitalizationType: String?
        let submitButton: String?
    }
}
