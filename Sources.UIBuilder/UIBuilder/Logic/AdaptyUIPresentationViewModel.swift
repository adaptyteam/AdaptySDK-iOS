//
//  AdaptyUIPresentationViewModel.swift
//  AdaptyUIBUilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyUIPresentationViewModel: ObservableObject {
    enum PresentationState {
        case initial
        case appeared
        case disappeared
    }

    @Published var presentationState: PresentationState = .initial

    let logId: String
    let logic: AdaptyUIBuilderLogic

    package init(
        logId: String,
        logic: AdaptyUIBuilderLogic
    ) {
        self.logId = logId
        self.logic = logic
    }

    func viewDidAppear() {
        presentationState = .appeared
        logic.reportViewDidAppear()
    }

    func viewDidDisappear() {
        presentationState = .disappeared
        logic.reportViewDidDisappear()
    }
}

#endif
