//
//  RecipesViewController.swift
//  AdaptyRecipes-UIKit
//
//  Created by Aleksey Goncharov on 08.08.2024.
//

import Adapty
import AdaptyUI
import UIKit

class RecipesViewController: UITableViewController {
    let viewModel = MainViewModel.shared
    let placementId = AppConstants.placementId

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if #available(iOS 15.0, *) {
                Task {
                    await presentPaywall()
                }
            }
        }
    }

    @available(iOS 15.0, *)
    private func presentPaywall() async {
        do {
            let paywall = try await Adapty.getPaywall(placementId: placementId)
            let viewConfig = try await AdaptyUI.getViewConfiguration(forPaywall: paywall)

            let vc = try AdaptyUI.paywallController(for: paywall,
                                                    viewConfiguration: viewConfig,
                                                    delegate: self)

            present(vc, animated: true)
        } catch {
            Logger.log(.error, "presentPaywall: \(error)")
        }
    }
}

@available(iOS 15.0, *)
extension RecipesViewController: AdaptyPaywallControllerDelegate {
    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailPurchase product: AdaptyPaywallProduct,
        error: AdaptyError
    ) {
        // handle the error
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFinishRestoreWith profile: AdaptyProfile
    ) {
        // handle the restore result
    }

    func paywallController(
        _ controller: AdaptyPaywallController,
        didFailRestoreWith error: AdaptyError
    ) {
        // handle the error
    }
}
