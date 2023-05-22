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

        UIScrollView.appearance().keyboardDismissMode = .onDrag
        navigationItem.title = "Welcome to Adapty!"

        addSubSwiftUIView(
            MainControllerView()
                .environmentObject(presenter),
            to: view)

        presenter.$errors
            .sink(receiveValue: { [weak self] v in
                guard let error = v.last else { return }
                self?.showError(error.error)
            })
            .store(in: &cancellable)
    }

    private func showError(_ error: AdaptyError) {
        let alert = UIAlertController(title: "Error \(error.errorCode)",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}
