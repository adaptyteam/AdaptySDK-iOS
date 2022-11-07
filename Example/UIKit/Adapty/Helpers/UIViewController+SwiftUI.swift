//
//  UIViewController+SwiftUI.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 29.09.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import SwiftUI
import UIKit

public extension UIViewController {
    /// Add a SwiftUI `View` as a child of the input `UIView`.
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI `View` to add as a child.
    ///   - view: The `UIView` instance to which the view should be added.
    @discardableResult
    func addSubSwiftUIView<Content>(_ swiftUIView: Content, to view: UIView, hostingViewColor: UIColor = .clear) -> UIView where Content: View {
        let hostingController = UIHostingController(rootView: swiftUIView)

        /// Add as a child of the current view controller.
        addChild(hostingController)

        hostingController.view.backgroundColor = hostingViewColor

        /// Add the SwiftUI view to the view controller view hierarchy.
        view.addSubview(hostingController.view)

        /// Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor),
        ]

        NSLayoutConstraint.activate(constraints)

        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)

        return hostingController.view
    }
}
