//
//  AdaptyOnboardingsCustomAction.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

public struct AdaptyOnboardingsCustomAction: Sendable, Hashable {
    public let actionId: String
    public let meta: AdaptyOnboardingsMetaParams

    init(_ body: BodyDecoder.Dictionary) throws {
        self.actionId = try body["action_id"].asString()
        self.meta = try AdaptyOnboardingsMetaParams(body["meta"])
    }
}

extension AdaptyOnboardingsCustomAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{actionId: \(actionId), meta: \(meta.debugDescription)}"
    }
}
