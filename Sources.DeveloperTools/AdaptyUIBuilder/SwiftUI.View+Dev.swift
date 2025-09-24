//
//  SwiftUI.View+Extension.swift
//  AdaptyDeveloperTools
//
//  Created by Aleksei Valiano on 24.09.2025.
//

#if canImport(UIKit)
import SwiftUI
import AdaptyUIBuider

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension View {
    func dev_withScreenSize(_ value: CGSize) -> some View {
        withScreenSize(value)
    }
    
    @available(*, deprecated, renamed: "dev_withScreenSize")
    func withScreenSizeTestingWrapper(_ value: CGSize) -> some View {
        dev_withScreenSize(value)
    }
}
#endif
