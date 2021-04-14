//
//  ResponseHashManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 09.04.2021.
//

import Foundation

class ResponseHashManager {
    
    enum RouterType: String {
        case none
        case getPaywalls
        case getPurchaserInfo
        case getPromo
    }
    
    static let shared = ResponseHashManager()
    
    private var previousResponseHashes: [String: String] {
        get {
            return DefaultsManager.shared.previousResponseHashes
        }
        set {
            DefaultsManager.shared.previousResponseHashes = newValue
        }
    }
    private(set) var responseJSONCaches: [String: [String: Data]] {
        get {
            return DefaultsManager.shared.responseJSONCaches
        }
        set {
            DefaultsManager.shared.responseJSONCaches = newValue
        }
    }
    
    func tryToGetCachedJSONObject(for data: Data, response: HTTPURLResponse, router: Router?) -> Parameters? {
        guard let routerType = router?.routerType, routerType != .none else {
            return nil
        }
        
        guard let hash = response.allHeaderFields[Constants.Headers.xResponseHash] as? String else {
            return nil
        }
        
        previousResponseHashes[routerType.rawValue] = hash
        
        if let cachedResponse = responseJSONCaches[routerType.rawValue]?[hash] {
            return try? JSONSerialization.jsonObject(with: cachedResponse, options: []) as? Parameters
        } else {
            responseJSONCaches[routerType.rawValue] = [hash: data]
        }
        
        return nil
    }
    
    func tryToAddHashHeader(for router: Router, in request: inout URLRequest) {
        request.setValue(previousResponseHashes[router.routerType.rawValue], forHTTPHeaderField: Constants.Headers.previousResponseHash)
    }

}

fileprivate extension Router {
    
    var routerType: ResponseHashManager.RouterType {
        switch self {
        case .getPaywalls:
            return .getPaywalls
        case .getPurchaserInfo:
            return .getPurchaserInfo
        case .getPromo:
            return .getPromo
        default:
            return .none
        }
    }
    
}
