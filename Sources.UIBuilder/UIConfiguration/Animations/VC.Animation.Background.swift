//
//  VC.Animation.Background.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 11.02.2026.
//

import Foundation

package extension VC.Animation {
    struct Background: Sendable, Hashable {
        package let timeline: Timeline
        package let range: Range<VC.AssetReference>
    }
}
