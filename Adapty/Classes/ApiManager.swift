//
//  ApiManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public typealias ProfileCreateCompletion = (PurchaserInfoModel?, AdaptyError?, Bool?) -> Void
typealias InstallationCompletion = (InstallationModel?, AdaptyError?) -> Void
public typealias PaywallCompletion = (PaywallModel?, AdaptyError?) -> Void
public typealias ProductsCompletion = ([ProductModel]?, AdaptyError?) -> Void
public typealias ValidateReceiptCompletion = (PurchaserInfoModel?, Parameters?, AdaptyError?) -> Void
public typealias SyncTransactionsHistoryCompletion = (Parameters?, [ProductModel]?, AdaptyError?) -> Void
public typealias JSONCompletion = (Parameters?, AdaptyError?) -> Void
public typealias ErrorCompletion = (AdaptyError?) -> Void
public typealias PurchaserCompletion = (PurchaserInfoModel?, AdaptyError?) -> Void

class ApiManager {
    private let requestManager: RequestManager

    init(requestManager: RequestManager = .shared) {
        self.requestManager = requestManager
    }

    func createProfile(id: String, params: Parameters, completion: @escaping ProfileCreateCompletion) {
        requestManager.request(router: Router.createProfile(id: id, params: params)) { (result: Result<PurchaserInfoModel, AdaptyError>, response) in
            switch result {
            case let .success(purchaserInfo):
                completion(purchaserInfo, nil, response?.statusCode == 201 ? true : false)
            case let .failure(error):
                completion(nil, error, nil)
            }
        }
    }

    func updateProfile(id: String, params: Parameters, completion: @escaping JSONCompletion) {
        requestManager.request(router: Router.updateProfile(id: id, params: params)) { (result: Result<JSONAttributedModel, AdaptyError>, response) in
            switch result {
            case let .success(response):
                completion(response.data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func syncInstallation(id: String, profileId: String, params: Parameters, completion: @escaping InstallationCompletion) {
        requestManager.request(router: Router.syncInstallation(id: id, profileId: profileId, params: params)) { (result: Result<InstallationModel, AdaptyError>, _) in
            switch result {
            case let .success(installation):
                completion(installation, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func validateReceipt(params: Parameters, completion: @escaping ValidateReceiptCompletion) {
        requestManager.request(router: Router.validateReceipt(params: params)) { (result: Result<PurchaserInfoMeta, AdaptyError>, response) in
            switch result {
            case let .success(response):
                completion(response.purchaserInfo, response.appleValidationResult, nil)
            case let .failure(error):
                completion(nil, nil, error)
            }
        }
    }

    @discardableResult
    func getPaywall(id: String, params: Parameters, completion: @escaping PaywallCompletion) -> URLSessionDataTask? {
        return requestManager.request(router: Router.getPaywall(id: id, params: params)) { (result: Result<PaywallModel, AdaptyError>, _) in
            switch result {
            case let .success(paywall):
                completion(paywall, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    @discardableResult
    func getProducts(params: Parameters, completion: @escaping ProductsCompletion) -> URLSessionDataTask? {
        return requestManager.request(router: Router.getProducts(params: params)) { (result: Result<ProductsArray, AdaptyError>, _) in
            switch result {
            case let .success(data):
                completion(data.products, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func signSubscriptionOffer(params: Parameters, completion: @escaping JSONCompletion) {
        requestManager.request(router: Router.signSubscriptionOffer(params: params)) { (result: Result<JSONAttributedModel, AdaptyError>, response) in
            switch result {
            case let .success(response):
                completion(response.data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func getPurchaserInfo(id: String, completion: @escaping PurchaserCompletion) {
        requestManager.request(router: Router.getPurchaserInfo(id: id)) { (result: Result<PurchaserInfoModel, AdaptyError>, _) in
            switch result {
            case let .success(purchaserInfo):
                completion(purchaserInfo, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func updateAttribution(id: String, params: Parameters, completion: @escaping JSONCompletion) {
        requestManager.request(router: Router.updateAttribution(id: id, params: params)) { (result: Result<JSONModel, AdaptyError>, response) in
            switch result {
            case let .success(response):
                completion(response.data, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    func enableAnalytics(id: String, params: Parameters, completion: ErrorCompletion?) {
        requestManager.request(router: Router.enableAnalytics(id: id, params: params)) { (result: Result<JSONModel, AdaptyError>, _) in
            if case let .failure(error) = result {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }

    func setTransactionVariationId(params: Parameters, completion: ErrorCompletion?) {
        requestManager.request(router: Router.setTransactionVariationId(params: params)) { (result: Result<JSONModel, AdaptyError>, _) in
            if case let .failure(error) = result {
                completion?(error)
            } else {
                completion?(nil)
            }
        }
    }
}
