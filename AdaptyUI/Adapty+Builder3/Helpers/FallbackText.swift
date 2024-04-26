//
//  FallbackText.swift
//
//
//  Created by Aleksey Goncharov on 4.4.24..
//

import SwiftUI
import UIKit

struct FallbackText: UIViewRepresentable {
    typealias FallbackView = UILabel

    var attributedText: NSAttributedString
    
    init(_ attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> FallbackView {
        let v = FallbackView()
        
        v.numberOfLines = 0
        v.attributedText = attributedText
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }

    func updateUIView(_ uiView: FallbackView, context: UIViewRepresentableContext<Self>) {
    }
}
