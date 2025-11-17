//
//  SwiftUI+ScrollView.swift
//
//
//  Created by Aleksey Goncharov on 24.06.2024.
//

#if canImport(UIKit)

import SwiftUI

extension View {
    @ViewBuilder
    func scrollIndicatorsHidden_compatible() -> some View {
        if #available(iOS 16.0, *) {
            scrollIndicators(.hidden)
        } else {
            self
        }
    }
}

#endif
