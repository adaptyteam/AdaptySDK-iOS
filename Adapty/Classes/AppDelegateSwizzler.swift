//
//  AppDelegateSwizzler.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 10/12/2019.
//

import Foundation
import UIKit

protocol AppDelegateSwizzlerDelegate: class {
    func didReceiveAPNSToken(_ deviceToken: Data)
}

private typealias RegisterForNotificationsClosureType = @convention(c) (AnyObject, Selector, UIApplication, Data) -> Void

class AppDelegateSwizzler {
    
    private static let shared = AppDelegateSwizzler()
    private weak var delegate: AppDelegateSwizzlerDelegate?
    private static var registerForNotificationsOriginalImp: RegisterForNotificationsClosureType?
    
    class func startSwizzlingIfPossible(_ delegate: AppDelegateSwizzlerDelegate) {
        // check if user disabled swizzling
        if let appDelegateProxyEnabled = Bundle.main.infoDictionary?[Constants.BundleKeys.appDelegateProxyEnabled] as? Bool, !appDelegateProxyEnabled {
            return
        }
        
        shared.delegate = delegate
    }
    
    private init() {
        DispatchQueue.main.async {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
            guard
                let originalClass = object_getClass(UIApplication.shared.delegate),
                let swizzledClass = object_getClass(self)
            else { return }
            
            let originalSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
            let swizzledSelector = #selector(self.swizzled_application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
            
            self.swizzle(originalClass, swizzledClass, originalSelector, swizzledSelector)
        }
    }
    
    private func swizzle(_ originalClass: AnyClass, _ swizzledClass: AnyClass, _ originalSelector: Selector, _ swizzledSelector: Selector) {
        guard let swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector) else {
            return
        }
        
        if let originalMethod = class_getInstanceMethod(originalClass, originalSelector) {
            let imp = method_getImplementation(originalMethod)
            AppDelegateSwizzler.registerForNotificationsOriginalImp = unsafeBitCast(imp, to: RegisterForNotificationsClosureType.self)
            
            // exchange implementation
            method_exchangeImplementations(originalMethod, swizzledMethod)
        } else {
           // add implementation
           class_addMethod(originalClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        }
    }
    
    @objc private func swizzled_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // call parent method
        AppDelegateSwizzler.registerForNotificationsOriginalImp?(UIApplication.shared.delegate!, #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)), application, deviceToken)
        
        // sync token to Adapty
        Self.shared.delegate?.didReceiveAPNSToken(deviceToken)
    }
    
}
