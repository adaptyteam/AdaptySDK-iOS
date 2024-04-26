//
//  AdaptyLimitOverscrollScrollBehaviour.swift
//
//
//  Created by Alexey Goncharov on 16.8.23..
//

import UIKit

struct AdaptyLimitOverscrollScrollBehaviour: AdaptyScrollViewBehaviour {
    let maxOffsetTop: CGFloat?
    let maxOffsetBottom: CGFloat?

    init(
        maxOffsetTop: CGFloat? = 64.0,
        maxOffsetBottom: CGFloat = 64.0
    ) {
        self.maxOffsetTop = maxOffsetTop
        self.maxOffsetBottom = maxOffsetBottom
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset

        if let maxOffsetTop = maxOffsetTop,
           contentOffset.y < -maxOffsetTop {
            contentOffset = CGPoint(x: contentOffset.x, y: -maxOffsetTop)
        }
        if let maxOffsetBottom = maxOffsetBottom {
            if scrollView.contentSize.height > scrollView.frame.height &&
                contentOffset.y > scrollView.contentSize.height - scrollView.frame.height + maxOffsetBottom {
                contentOffset = CGPoint(x: contentOffset.x,
                                        y: scrollView.contentSize.height - scrollView.frame.height + maxOffsetBottom)
            }

            if scrollView.contentSize.height <= scrollView.frame.height &&
                contentOffset.y > maxOffsetBottom {
                contentOffset = CGPoint(x: contentOffset.x,
                                        y: maxOffsetBottom)
            }
        }

        scrollView.contentOffset = contentOffset
    }
}
