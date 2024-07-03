//
//  MainViewModel.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.11.23..
//

import Adapty
import AdaptyUI
import Combine
import Foundation

class MainViewModel: ObservableObject {
    var onError: ((Error) -> Void)?

    @Published var paywall: AdaptyPaywall?
    @Published var viewConfig: AdaptyUI.LocalizedViewConfiguration?

    @MainActor
    func loadPaywall(id: String) async {
        do {
            let paywall = try await Adapty.getPaywall(placementId: id)
            self.paywall = paywall
        } catch {
            onError?(error)
        }
    }

    @MainActor
    func loadViewConfiguration() async {
        guard let paywall = paywall else { return }

        do {
            let viewConfig = try await AdaptyUI.getViewConfiguration(forPaywall: paywall)
            self.viewConfig = viewConfig
        } catch {
            onError?(error)
        }
    }
}
