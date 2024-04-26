//
//  AdaptyCoverImageScrollBehaviour.swift
//  
//
//  Created by Alexey Goncharov on 16.8.23..
//

import UIKit

struct AdaptyCoverImageScrollBehaviour: AdaptyScrollViewBehaviour {
    let coverView: UIView

    init(coverView: UIView) {
        self.coverView = coverView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        modifyCoverViewTransform(scrollView.contentOffset)
    }

    private func modifyCoverViewTransform(_ contentOffset: CGPoint) {
        if contentOffset.y < 0.0 {
            let diff = abs(contentOffset.y)
            let scale = (coverView.bounds.size.height + 2.0 * diff) / coverView.bounds.size.height
            coverView.transform = .init(scaleX: scale, y: scale)
        } else if contentOffset.y > 0.0 {
            coverView.transform = .init(translationX: 0.0, y: -contentOffset.y / 2.0)
        } else {
            coverView.transform = .identity
        }
    }
}
