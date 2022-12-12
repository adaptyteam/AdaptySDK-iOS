//
//  LogsController.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 01.11.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import UIKit

class LogsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Logs"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonPressed))
        
        addSubSwiftUIView(
            LogsListView()
                .environmentObject(LogsObserver.shared),
            to: view)
    }
    
    @objc
    private func shareButtonPressed() {
        guard let fileURL = LogsObserver.shared.saveLogToFile() else { return }
        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        present(vc, animated: true)
    }
}
