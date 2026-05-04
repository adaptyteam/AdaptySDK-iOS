//
//  SwiftUI.View+Extension.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)
import SwiftUI
import AdaptyUIBuilder

public extension View {
    func dev_withScreenSize(_ value: CGSize) -> some View {
        withScreenSize(value)
    }
}
#endif
