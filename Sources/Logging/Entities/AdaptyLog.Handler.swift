//
//  AdaptyLog.Handler.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

package extension Log {
    typealias Handler = AdaptyLog.Handler
}

public extension AdaptyLog {
    typealias Handler = @Sendable (Record) -> Void
}
