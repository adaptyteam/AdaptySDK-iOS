//
//  VC.Variable.Converter.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.02.2026.
//

import Foundation

extension VC.Variable {


    enum Converter: Sendable, Hashable {
        case isEqual(VC.Constant, `false`:VC.Constant? )

        case unknown(String, VC.Constant?)
    }
}
