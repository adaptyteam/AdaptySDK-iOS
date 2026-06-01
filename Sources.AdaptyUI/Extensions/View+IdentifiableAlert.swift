//
//  View+IdentifiableAlert.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import SwiftUI

public struct AdaptyIdentifiablePlaceholder: Identifiable {
    public var id: String { "placeholder" }
}

@MainActor
extension View {
    @ViewBuilder
    func withAlert<AlertItem>(
        item: Binding<AlertItem?>,
        builder: ((AlertItem) -> Alert)?
    ) -> some View where AlertItem: Identifiable {
        if let builder {
            alert(item: item) { builder($0) }
        } else {
            self
        }
    }
}
