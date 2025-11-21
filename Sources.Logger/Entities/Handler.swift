//
//  Handler.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

public extension AdaptyLogger {
    typealias Handler = @Sendable (Record) -> Void
}
