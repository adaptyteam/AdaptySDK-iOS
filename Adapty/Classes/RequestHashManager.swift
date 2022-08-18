//
//  RequestHashManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 09.04.2021.
//

import Foundation

class RequestHashManager {

    enum RouterPOSTType: String {
        case none
        case updateAttribution
        case updateProfile
        case syncInstallation
    }

    static let shared = RequestHashManager()

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

    private(set) var postRequestParamsHashes: [String: String] {
        get {
            return DefaultsManager.shared.postRequestParamsHashes
        }
        set {
            DefaultsManager.shared.postRequestParamsHashes = newValue
        }
    }

    func tryToGetCachedJSONObject(for data: Data, response: HTTPURLResponse, router: Router?) -> Parameters? {
        guard
            let hashKey = router?.hashKey,
            let hash = response.allHeaderFields[API.Headers.xResponseHash] as? String
        else {
            return nil
        }

        previousResponseHashes[hashKey] = hash

        if let cachedResponse = responseJSONCaches[hashKey]?[hash] {
            return try? JSONSerialization.jsonObject(with: cachedResponse, options: []) as? Parameters
        } else {
            responseJSONCaches[hashKey] = [hash: data]
        }

        return nil
    }

    func tryToAddHashHeader(for router: Router, in request: inout URLRequest) {
        guard let hashKey = router.hashKey, let value = previousResponseHashes[hashKey] else { return }
        request.setValue(value, forHTTPHeaderField: API.Headers.previousResponseHash)
    }

    func isPostHashExists(for routerType: RouterPOSTType, source: AttributionNetwork? = nil, params: Parameters) -> Bool {
        var hashPath = routerType.rawValue
        if let source = source {
            hashPath.append("/\(source.rawSource)")
        }

        guard let hashCache = postRequestParamsHashes[hashPath] else {
            return false
        }

        return hashCache == params.hashValue
    }

    func storePostHash(for routerType: RouterPOSTType, source: AttributionNetwork? = nil, params: Parameters) {
        var hashPath = routerType.rawValue
        if let source = source {
            hashPath.append("/\(source.rawSource)")
        }

        postRequestParamsHashes[hashPath] = params.hashValue
    }
}

fileprivate extension Parameters {
    var hashValue: String {
        let sortedKeys = keys.sorted(by: <)
        let sortedValues = sortedKeys.map { key -> String in
            let value = self[key]
            if let parametersValue = value as? Parameters {
                return "\(key): [\(parametersValue.hashValue)]"
            } else {
                return "\(key): \(value ?? "")"
            }
        }

        return sortedValues.joined(separator: "; ")
    }
}

fileprivate extension Router {
    var hashKey: String? {
        switch self {
        case .getProducts:
            return "getProducts"
        case .getPurchaserInfo:
            return "getPurchaserInfo"
        case let .getPaywall( id, _):
            return "getPaywallById_\(id)"
        default:
            return nil
        }
    }
}

