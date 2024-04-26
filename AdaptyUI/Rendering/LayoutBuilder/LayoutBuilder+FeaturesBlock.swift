//
//  LayoutBuilder+FeaturesBlock.swift
//
//
//  Created by Alexey Goncharov on 8.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutFeaturesBlock(_ block: AdaptyUI.OldFeaturesBlock,
                             _ tagConverter: AdaptyUI.CustomTagConverter?,
                             in stackView: UIStackView) throws {
        switch block.type {
        case .list:
            guard let text = block.items["list"]?.asText else {
                throw AdaptyUIError.componentNotFound("list")
            }

            try layoutText(
                text,
                tagConverter,
                paragraph: .init(paragraphSpacing: 8.0),
                in: stackView
            )
        case .timeline:
            let featuresTimelineView = try AdaptyTimelineComponentView(
                block: block,
                tagConverter: tagConverter
            )
            stackView.addArrangedSubview(featuresTimelineView)
        }
    }
}
