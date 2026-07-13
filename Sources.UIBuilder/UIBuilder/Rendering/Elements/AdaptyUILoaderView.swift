//
//  AdaptyUILoaderView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

struct AdaptyUILoaderView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            ProgressView()
                .progressViewStyle(DefaultProgressViewStyle())
                .tint(.white)
                .scaleEffect(CGSize(width: 1.5, height: 1.5))
        }
    }
}

#Preview {
    AdaptyUILoaderView()
}

#endif
