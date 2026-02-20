//
//  AdaptyUIScreensViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 18.06.2024.
//


import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyUIBottomSheetViewModel: ObservableObject {
    @Published var isPresented: Bool = false

    var id: String
    var bottomSheet: VC.BottomSheet

    init(id: String, bottomSheet: VC.BottomSheet) {
        self.id = id
        self.bottomSheet = bottomSheet
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class AdaptyUIScreensViewModel: ObservableObject {
    private let logId: String
    private let viewConfiguration: AdaptyUIConfiguration
    private var macOSSheetConfigsById = [String: AdaptyMacOSSheetConfig]()

    let bottomSheetsViewModels: [AdaptyUIBottomSheetViewModel]

    @Published var presentedScreensStack = [String]()

    package var activePresentedBottomSheetId: String? {
        presentedScreensStack.last
    }

    package init(
        logId: String,
        viewConfiguration: AdaptyUIConfiguration
    ) {
        self.logId = logId
        self.viewConfiguration = viewConfiguration

        bottomSheetsViewModels = viewConfiguration.bottomSheets.map {
            .init(id: $0.key, bottomSheet: $0.value)
        }
    }

    func presentScreen(
        id: String,
        macOSSheetConfig: AdaptyMacOSSheetConfig? = nil
    ) {
        Log.ui.verbose("#\(logId)# presentScreen \(id)")

        if presentedScreensStack.contains(where: { $0 == id }) {
            Log.ui.warn("#\(logId)# presentScreen \(id) Already Presented!")
            return
        }

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                macOSSheetConfigsById[id] = macOSSheetConfig ?? .default
                bottomSheetVM.isPresented = true
                presentedScreensStack.append(id)
                return
            }
        }

        Log.ui.warn("#\(logId)# presentScreen \(id) Bottom Sheet Not Found!")
    }

    func dismissScreen(id: String) {
        Log.ui.verbose("#\(logId)# dismissScreen \(id)")
        presentedScreensStack.removeAll(where: { $0 == id })
        macOSSheetConfigsById[id] = nil

        for bottomSheetVM in bottomSheetsViewModels {
            if bottomSheetVM.id == id {
                bottomSheetVM.isPresented = false
            }
        }
    }

    func dismissTopScreen() {
        guard let topScreenId = presentedScreensStack.last else { return }

        dismissScreen(id: topScreenId)
    }

    package func resetScreensStack() {
        Log.ui.verbose("#\(logId)# resetScreensStack")
        presentedScreensStack.removeAll()
        macOSSheetConfigsById.removeAll()
        bottomSheetsViewModels.forEach { $0.isPresented = false }
    }

    package func macOSSheetConfig(for id: String) -> AdaptyMacOSSheetConfig {
        macOSSheetConfigsById[id] ?? .default
    }
}
