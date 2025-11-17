//
//  Dialog+Extensions.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

#if canImport(UIKit)

import UIKit

extension UIAlertController {
    static func create(
        _ configuration: AdaptyUI.DialogConfiguration,
        defaultActionHandler: @escaping () -> Void,
        secondaryActionHandler: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: configuration.title,
                                      message: configuration.content,
                                      preferredStyle: .alert)

        alert.addAction(
            .init(title: configuration.defaultAction.title,
                  style: .cancel)
            { _ in
                defaultActionHandler()
            }
        )

        if let secondaryAction = configuration.secondaryAction {
            alert.addAction(
                .init(title: secondaryAction.title,
                      style: .default)
                { _ in
                    secondaryActionHandler()
                }
            )
        }

        return alert
    }
}

extension UIViewController {
    func showDialog(
        _ configuration: AdaptyUI.DialogConfiguration,
        defaultActionHandler: @escaping () -> Void,
        secondaryActionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController.create(configuration,
                                             defaultActionHandler: defaultActionHandler,
                                             secondaryActionHandler: secondaryActionHandler)
        present(alert, animated: true)
    }
}

#endif
