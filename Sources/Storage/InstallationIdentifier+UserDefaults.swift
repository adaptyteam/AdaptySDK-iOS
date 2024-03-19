//
//  InstallationIdentifier+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.10.2022.
//

import Foundation

extension Environment.Application {
    static let installationIdentifier = UserDefaults.standard.getAppInstallationIdentifier()
}

extension UserDefaults {
    fileprivate enum Constants {
        static let appInstallationIdentifier = "AdaptySDK_Application_Install_Identifier"
    }

    fileprivate func getAppInstallationIdentifier() -> String {
        if let identifier = string(forKey: Constants.appInstallationIdentifier) {
            return identifier
        }
        let identifier = UUID().uuidString.lowercased()
        Log.debug("UserDefaults: appInstallationIdentifier = \(identifier).")

        set(identifier, forKey: Constants.appInstallationIdentifier)
        return identifier
    }
}
