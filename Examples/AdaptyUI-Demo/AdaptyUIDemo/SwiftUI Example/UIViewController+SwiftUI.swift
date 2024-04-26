//
//  UIViewController+SwiftUI.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.11.23..
//

import SwiftUI
import UIKit

extension UIViewController {
    /// Add a SwiftUI `View` as a child of the input `UIView`.
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI `View` to add as a child.
    ///   - view: The `UIView` instance to which the view should be added.
    @discardableResult
    func addSubSwiftUIView<Content>(
        _ swiftUIView: Content,
        to view: UIView,
        useSafeArea: Bool = false,
        leadingInset: CGFloat? = 0.0,
        topInset: CGFloat? = 0.0,
        trailingInset: CGFloat? = 0.0,
        bottomInset: CGFloat? = 0.0
    ) -> UIHostingController<Content> where Content: View {
        let hostingController = UIHostingController(rootView: swiftUIView)

        /// Add as a child of the current view controller.
        addChild(hostingController)

        /// Add the SwiftUI view to the view controller view hierarchy.
        view.addSubview(hostingController.view)

        /// Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        var constraints = [NSLayoutConstraint]()

        if let topInset = topInset {
            constraints.append(
                hostingController
                    .view
                    .topAnchor
                    .constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor,
                                constant: topInset)
            )
        }

        if let leadingInset = leadingInset {
            constraints.append(
                hostingController
                    .view
                    .leadingAnchor
                    .constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor,
                                constant: leadingInset)
            )
        }

        if let trailingInset = trailingInset {
            constraints.append(
                hostingController
                    .view
                    .trailingAnchor
                    .constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor,
                                constant: trailingInset)
            )
        }

        if let bottomInset = bottomInset {
            constraints.append(
                hostingController
                    .view
                    .bottomAnchor
                    .constraint(equalTo: useSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor,
                                constant: bottomInset)
            )
        }

        NSLayoutConstraint.activate(constraints)

        /// Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)

        return hostingController
    }
}
