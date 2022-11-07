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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Welcome to Adapty!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logs",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(presentLogsController))

        addSubSwiftUIView(
            MainControllerView(onShowExamplePaywall: { [weak self] paywall, products in
                self?.presentPaywallController(paywall, products)
            })
            .environmentObject(presenter),
            to: view)
    }

    private func presentPaywallController(_ paywall: Paywall, _ products: [PaywallProduct]) {
        let isHorizontal = paywall.isHorizontal()

        let vc = isHorizontal ? PurchaseController.instantiateHorizontal() : PurchaseController.instantiateVertical()
        vc.presenter = PurchasePresenter(paywall: paywall, products: products, isHorizontalLayout: isHorizontal)
        vc.modalPresentationStyle = .fullScreen

        present(vc, animated: true)
    }

    @objc
    private func presentLogsController() {
        let vc = LogsController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}
