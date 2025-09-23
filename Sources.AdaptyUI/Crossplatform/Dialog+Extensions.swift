//
//  Dialog+Extensions.swift
//  Adapty
//
//  Created by Aleksey Goncharov on 13.11.2024.
//

#if canImport(UIKit)

import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
