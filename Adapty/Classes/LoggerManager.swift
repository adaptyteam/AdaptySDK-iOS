//
//  LoggerManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/04/2020.
//

import Foundation

@objc public enum AdaptyLogLevel: Int {
    case none
    case errors
    case verbose
}

class LoggerManager {
    
    static var logLevel: AdaptyLogLevel = .none
    
    class func logError(_ error: Any) {
        guard isAllowedToLog(.errors) else {
            return
        }
        
        NSLog("\(prefix) ERROR.\n\(error)")
    }
    
    class func logMessage(_  message: String) {
        guard isAllowedToLog(.verbose) else {
            return
        }
        
        NSLog("\(prefix) INFO.\n\(message)")
    }
    
    private class func isAllowedToLog(_ level: AdaptyLogLevel) -> Bool {
        return logLevel.rawValue >= level.rawValue
    }
    
    private class var prefix: String {
        return "[Adapty v\(UserProperties.sdkVersion ?? "")(\(UserProperties.sdkVersionBuild))]"
    }
    
}
