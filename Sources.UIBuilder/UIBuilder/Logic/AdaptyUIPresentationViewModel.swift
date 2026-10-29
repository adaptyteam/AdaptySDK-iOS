//
//  AdaptyUIPresentationViewModel.swift
//  AdaptyUIBUilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

#if canImport(UIKit)

import Foundation

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

    package func viewDidAppear() {
        presentationState = .appeared
        logic.reportViewDidAppear()
    }

    package func viewDidDisappear() {
        presentationState = .disappeared
        logic.reportViewDidDisappear()
    }

    package func prepareForReuse() {
        Log.ui.verbose("#\(logId)# prepareForReuse")
        presentationState = .initial
    }
}

#endif
