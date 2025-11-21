//
//  OnboardingsDidFinishLoadingAction.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

public struct OnboardingsDidFinishLoadingAction: Sendable, Hashable {
    public let meta: AdaptyOnboardingsMetaParams

    init(_ body: BodyDecoder.Dictionary) throws {
        self.meta = try AdaptyOnboardingsMetaParams(body["meta"])
    }
}

extension OnboardingsDidFinishLoadingAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{meta: \(meta.debugDescription)}"
    }
}
