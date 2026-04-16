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
    }
}

extension Schema.EventHandler: Decodable {
    enum CodingKeys: String, CodingKey {
        case triggers
        case animations
        case onAnimationsFinish = "on_animations_finish"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var triggers = try container.decode([Schema.EventHandler.Trigger].self, forKey: .triggers)
        triggers = triggers.filter { !$0.isEmpty }

        guard !triggers.isEmpty else {
            self.init(
                triggers: [],
                animations: [],
                onAnimationsFinish: []
            )
            return
        }

        let animations = try container.decode([Schema.Animation].self, forKey: .animations)

        guard !animations.isEmpty else {
            self.init(
                triggers: [],
                animations: [],
                onAnimationsFinish: []
            )
            return
        }

        try self.init(
            triggers: triggers,
            animations: animations,
            onAnimationsFinish: container.decodeIfPresentActions(forKey: .onAnimationsFinish) ?? []
        )
    }
}

