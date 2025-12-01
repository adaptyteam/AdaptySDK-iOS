//
//  VC.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension VC {
    struct Pager: Sendable, Hashable {
        package let pageWidth: Length
        package let pageHeight: Length
        package let pagePadding: EdgeInsets
        package let spacing: Double
        package let content: [Element]
        package let pageControl: PageControl?
        package let animation: Animation?
        package let interactionBehavior: InteractionBehavior
    }
}

extension VC.Pager {
    static let `default` = Self(
        pageWidth: .default,
        pageHeight: .default,
        pagePadding: .zero,
        spacing: 0,
        content: [],
        pageControl: nil,
        animation: nil,
        interactionBehavior: .default
    )
}

#if DEBUG
package extension VC.Pager {
    static func create(
        pageWidth: Length = `default`.pageWidth,
        pageHeight: Length = `default`.pageHeight,
        pagePadding: VC.EdgeInsets = `default`.pagePadding,
        spacing: Double = `default`.spacing,
        content: [VC.Element] = `default`.content,
        pageControl: PageControl? = `default`.pageControl,
        animation: Animation? = `default`.animation,
        interactionBehaviour: InteractionBehavior = `default`.interactionBehavior
    ) -> Self {
        .init(
            pageWidth: pageWidth,
            pageHeight: pageHeight,
            pagePadding: pagePadding,
            spacing: spacing,
            content: content,
            pageControl: pageControl,
            animation: animation,
            interactionBehavior: interactionBehaviour
        )
    }
}
#endif
