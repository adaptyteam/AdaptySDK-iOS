//
//  MainController.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Combine
import UIKit

class MainController: UIViewController {
    private var cancellable = Set<AnyCancellable>()
    private let presenter = MainPresenter()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Welcome to Adapty!"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension

        presenter.$items
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellable)

        presenter.reloadData()
    }

    private func presentPaywallController(_ paywall: PaywallModel) {
        let isHorizontal = paywall.isHorizontal()
        
        let vc = isHorizontal ? PurchaseController.instantiateHorizontal() : PurchaseController.instantiateVertical()
        vc.presenter = PurchasePresenter(paywall: paywall, isHorizontalLayout: isHorizontal)
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }

    fileprivate func showPaywall() {
        if let paywall = PurchasesObserver.shared.paywall {
            presentPaywallController(paywall)
        }
    }
}

extension PurchaserInfoModel {
    var descriptionString: String {
        """
        'premium' is active: \(accessLevels["premium"]?.isActive ?? false)\n
        accessLevels:\n\(accessLevels)
        subscriptions:\n\(subscriptions)
        Non subscriptions:\n\(nonSubscriptions)
        """
    }
}

extension MainController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = presenter.items[indexPath.row]

        switch item {
        case let .customerUserId(userId):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerDefaultCell", for: indexPath) as! MainControllerDefaultCell
            cell.update(title: "Customer User Id", subtitle: userId ?? "Not set")
            cell.selectionStyle = .none
            return cell
        case .updateUserId:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerTextFieldCell", for: indexPath) as! MainControllerTextFieldCell
            cell.update { [weak self] userId in
                guard let userId = userId, !userId.isEmpty else { return }
                self?.presenter.identifyUser(userId)
            }
            return cell
        case let .getPurchaserInfoResult(purchaserInfo):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerDefaultCell", for: indexPath) as! MainControllerDefaultCell
            cell.selectionStyle = .none

            if let purchaserInfo = purchaserInfo {
                cell.update(title: "Purchaser Info", subtitle: purchaserInfo.descriptionString)
            } else {
                cell.update(title: "Purchaser Info", subtitle: "null")
            }

            return cell
        case .getPurchaserInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerActionCell", for: indexPath) as! MainControllerActionCell
            cell.update(title: "Get Purchaser Info", style: .default)
            return cell
        case .updateProfile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerActionCell", for: indexPath) as! MainControllerActionCell
            cell.update(title: "Update Profile", style: .default)
            return cell
        case .updateAttribution:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerActionCell", for: indexPath) as! MainControllerActionCell
            cell.update(title: "Update Attribution", style: .default)
            return cell
        case .showPaywall:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerActionCell", for: indexPath) as! MainControllerActionCell
            cell.update(title: "Show Paywall", style: .default)
            return cell
        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerActionCell", for: indexPath) as! MainControllerActionCell
            cell.update(title: "Logout", style: .destructive)
            return cell
        case let .lastError(error):
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainControllerDefaultCell", for: indexPath) as! MainControllerDefaultCell
            if let error = error {
                cell.update(title: "Last Error", subtitle: error.localizedDescription)
            } else {
                cell.update(title: "Last Error", subtitle: "No errors occured")
            }

            cell.selectionStyle = .none
            return cell
        }
    }
}

extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = presenter.items[indexPath.row]

        switch item {
        case .getPurchaserInfo:
            presenter.getPurchaserInfo()
        case .updateProfile:
            presenter.updateProfileAttributes()
        case .updateAttribution:
            presenter.updateAttribution()
        case .showPaywall:
            showPaywall()
        case .logout:
            presenter.logout()
        default:
            break
        }
    }
}
