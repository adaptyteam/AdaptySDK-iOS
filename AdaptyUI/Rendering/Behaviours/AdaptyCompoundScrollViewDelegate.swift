//
//  AdaptyCoverImageScrollDelegate.swift
//
//
//  Created by Alexey Goncharov on 2023-01-18.
//

import UIKit

protocol AdaptyScrollViewBehaviour {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class AdaptyCompoundScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var behaviours = [AdaptyScrollViewBehaviour]()

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        behaviours.forEach { $0.scrollViewDidScroll(scrollView) }
    }
}
