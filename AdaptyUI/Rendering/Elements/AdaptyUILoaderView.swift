//
//  AdaptyUILoaderView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
#Preview {
    AdaptyUILoaderView()
}

#endif
