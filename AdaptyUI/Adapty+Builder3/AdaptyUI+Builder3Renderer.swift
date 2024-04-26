//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI
import UIKit

public class AdaptyBuilder3PaywallController: UIViewController {
    fileprivate let logId: String

    public let id = UUID()
    private let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.logId = logId
        self.viewConfiguration = viewConfiguration

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let screen = viewConfiguration.screens.first?.value {
            view.backgroundColor = screen.background.asColor?.uiColor ?? .white

            if let mainBlock = screen.mainBlock {
                addSubSwiftUIView(
                    ZStack(alignment: .center) {
                        AdaptyUIElementView(mainBlock)
                        
                        VStack {
                            HStack {
                                Button("Dismiss") { [weak self] in
                                    self?.dismiss(animated: true)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    },
                    to: view
                )
            } else {
                addSubSwiftUIView(Text("No main block found"),
                                  to: view)
            }
        } else {
            view.backgroundColor = .white // TODO: remove

            addSubSwiftUIView(
                VStack {
                    Text("Rendering Failed!")
                    Button("Dismiss") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                },
                to: view
            )
        }
    }

    deinit {
        log(.verbose, "deinit")
    }
}

extension AdaptyBuilder3PaywallController {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
