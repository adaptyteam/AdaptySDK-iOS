//
//  AdaptyPlacementChosen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.03.2024
//

import Foundation

enum AdaptyPlacementChosen<Content: AdaptyPlacementContent>: Sendable {
    case restore(Content)
    case draw(AdaptyPlacement.Draw<Content>)
}

extension AdaptyPlacementChosen {
    var content: Content {
        switch self {
        case let .restore(content):
            content
        case let .draw(draw):
            draw.content
        }
    }
}
