//
//  VC.Animation.Background.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

extension VC.Animation {
    struct Background: Sendable, Hashable {
        let timeline: Timeline
        let range: Range<VC.AssetReference>
    }
}
