//
//  AdaptyCoverImageScrollDelegate.swift
//
//
//  Created by Alexey Goncharov on 2023-01-18.
//

#if canImport(UIKit)

import UIKit

@available(iOS 15.0, *)
protocol AdaptyScrollViewBehaviour {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

@available(iOS 15.0, *)
class AdaptyCompoundScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var behaviours = [AdaptyScrollViewBehaviour]()

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        behaviours.forEach { $0.scrollViewDidScroll(scrollView) }
    }
}

#endif
