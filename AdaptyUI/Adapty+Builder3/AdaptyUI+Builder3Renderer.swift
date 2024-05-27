//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Adapty
import SwiftUI
import UIKit

@available(iOS 15.0, *)
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

         let screen = viewConfiguration.screen
            view.backgroundColor = screen.background.asColor?.uiColor ?? .white

            addSubSwiftUIView(
                ZStack(alignment: .center) {
                    AdaptyUIElementView(screen.content)

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

      
    }

    deinit {
        log(.verbose, "deinit")
    }
}

@available(iOS 15.0, *)
extension AdaptyBuilder3PaywallController {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}

#endif
