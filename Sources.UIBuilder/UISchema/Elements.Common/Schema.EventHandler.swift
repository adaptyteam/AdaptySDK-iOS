//
//  Schema.EventHandler.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension Schema {
    typealias EventHandler = VC.EventHandler
}

extension Schema.EventHandler {
    @inlinable
    var isEmpty: Bool {
        triggers.isEmpty
            && animations.isEmpty
            && onAnimationsFinish.isEmpty
            && actions.isEmpty
    }
}

extension Schema.EventHandler: Codable {
    enum CodingKeys: String, CodingKey {
        case triggers
        case animations
        case onAnimationsFinish = "on_animations_finish"
        case actions = "action"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var triggers = try container.decode([Schema.EventHandler.Trigger].self, forKey: .triggers)
        triggers = triggers.filter { !$0.isEmpty }
        if triggers.isEmpty {
            self.init(
                triggers: [],
                animations: [],
                onAnimationsFinish: [],
                actions: []
            )
        }

        let actions = try container.decodeIfPresentActions(forKey: .actions) ?? []

        if let animations = try container.decodeIfPresent([Schema.Animation].self, forKey: .animations), !animations.isEmpty {
            try self.init(
                triggers: triggers,
                animations: animations,
                onAnimationsFinish: container.decodeIfPresentActions(forKey: .onAnimationsFinish) ?? [],
                actions: actions
            )

        } else {
            self.init(
                triggers: triggers,
                animations: [],
                onAnimationsFinish: [],
                actions: actions
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(triggers, forKey: .triggers)
        try container.encode(animations, forKey: .animations)
        try container.encode(onAnimationsFinish, forKey: .onAnimationsFinish)
        try container.encode(actions, forKey: .actions)
    }
}

