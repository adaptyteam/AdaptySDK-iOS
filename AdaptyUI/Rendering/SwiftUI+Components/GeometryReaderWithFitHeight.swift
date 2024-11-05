//
//  GeometryWidthReader.swift
//
//
//  Created by Aleksey Goncharov on 27.06.2024.
//

#if canImport(UIKit)

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct GeometryReaderWithFitHeight<Content: View>: View {
    let contentBuilder: (CGFloat) -> Content

    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0

    var body: some View {
        GeometryReader { g in
            contentBuilder(width)
                .background(
                    GeometryReader { g1 in
                        Color.clear
                            .onAppear {
                                height = g1.size.height
                            }
                            .onChange(of: g1.size.height) {
                                height = $0
                            }
                    }
                )
                .onAppear {
                    width = g.size.width
                }
                .onChange(of: g.size.width) {
                    width = $0
                }
        }.frame(height: height)
    }
}

#endif
