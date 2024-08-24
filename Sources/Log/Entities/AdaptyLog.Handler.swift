//
//  AdaptyLog.Handler.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

extension Log {
    package typealias Handler = AdaptyLog.Handler
}

extension AdaptyLog {
    public typealias Handler = @Sendable (Record) -> Void
}
