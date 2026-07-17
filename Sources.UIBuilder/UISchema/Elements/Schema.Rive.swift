//
//  Schema.Rive.swift
//  AdaptyUIBuilder
//
//  Proof of concept: schema for the Rive animation element.
//

import Foundation

extension Schema {
    typealias Rive = VC.Rive
}

extension Schema.Rive: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        .rive(self, properties)
    }
}

extension Schema.Rive: Decodable {
    enum CodingKeys: String, CodingKey {
        case animationId = "animation_id"
        case artboard
        case stateMachine = "state_machine"
        case fit
        case autoplay
        case values
        case triggers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            animationId: container.decode(String.self, forKey: .animationId),
            artboard: container.decodeIfPresent(String.self, forKey: .artboard),
            stateMachine: container.decodeIfPresent(String.self, forKey: .stateMachine),
            fit: container.decodeIfPresent(AdaptyUIRiveFit.self, forKey: .fit) ?? .fit,
            autoplay: container.decodeIfPresent(Bool.self, forKey: .autoplay) ?? true,
            values: container.decodeIfPresent([String: AdaptyUIRiveValue].self, forKey: .values) ?? [:],
            triggers: container.decodeIfPresent([String].self, forKey: .triggers) ?? []
        )
    }
}
