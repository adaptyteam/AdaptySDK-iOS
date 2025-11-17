//
//  Dialog+Configuration.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

import Foundation

package extension AdaptyUI.DialogConfiguration {
    struct Action {
        package let title: String
        package init(title: String) {
            self.title = title
        }
    }
}

package extension AdaptyUI {
    struct DialogConfiguration {
        package let title: String?
        package let content: String?
        package let defaultAction: AdaptyUI.DialogConfiguration.Action
        package let secondaryAction: AdaptyUI.DialogConfiguration.Action?

        package init(
            title: String?,
            content: String?,
            defaultActionTitle: String,
            secondaryActionTitle: String?
        ) {
            self.title = title
            self.content = content
            self.defaultAction = .init(title: defaultActionTitle)
            self.secondaryAction = secondaryActionTitle.map(AdaptyUI.DialogConfiguration.Action.init)
        }
    }
}
