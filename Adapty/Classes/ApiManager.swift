//
//  ApiManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

public typealias ProfileCreateCompletion = (PurchaserInfoModel?, Error?, Bool?) -> Void
public typealias InstallationCompletion = (InstallationModel?, Error?) -> Void
public typealias PaywallsCompletion = ([PaywallModel]?, [ProductModel]?, Error?) -> Void
public typealias CachedPaywallsCompletion = ([PaywallModel]?, [ProductModel]?, DataState, Error?) -> Void
public typealias ValidateReceiptCompletion = (PurchaserInfoModel?, Parameters?, Error?) -> Void
public typealias JSONCompletion = (Parameters?, Error?) -> Void
public typealias ErrorCompletion = (Error?) -> Void
public typealias PurchaserCompletion = (PurchaserInfoModel?, Error?) -> Void
public typealias CahcedPurchaserCompletion = (PurchaserInfoModel?, DataState, Error?) -> Void
public typealias PromoCompletion = (PromoModel?, Error?) -> Void

class ApiManager {
    
    func createProfile(id: String, params: Parameters, completion: @escaping ProfileCreateCompletion) {
        RequestManager.request(router: Router.createProfile(id: id, params: params)) { (result: Result<PurchaserInfoModel, Error>, response) in
            switch result {
            case .success(let purchaserInfo):
                completion(purchaserInfo, nil, response?.statusCode == 201 ? true : false)
            case .failure(let error):
                completion(nil, error, nil)
            }
        }
    }
    
    func updateProfile(id: String, params: Parameters, completion: @escaping JSONCompletion) {
        RequestManager.request(router: Router.updateProfile(id: id, params: params)) { (result: Result<JSONAttributedModel, Error>, response) in
            switch result {
            case .success(let response):
                completion(response.data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func syncInstallation(id: String, profileId: String, params: Parameters, completion: @escaping InstallationCompletion) {
        RequestManager.request(router: Router.syncInstallation(id: id, profileId: profileId, params: params)) { (result: Result<InstallationModel, Error>, response) in
            switch result {
            case .success(let installation):
                completion(installation, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func validateReceipt(params: Parameters, completion: @escaping ValidateReceiptCompletion) {
        RequestManager.request(router: Router.validateReceipt(params: params)) { (result: Result<PurchaserInfoMeta, Error>, response) in
            switch result {
            case .success(let response):
                completion(response.purchaserInfo, response.appleValidationResult, nil)
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
    
    @discardableResult
    func getPaywalls(params: Parameters, completion: @escaping PaywallsCompletion) -> URLSessionDataTask? {
        return RequestManager.request(router: Router.getPaywalls(params: params)) { (result: Result<PaywallsArray, Error>, response) in
            switch result {
            case .success(let paywalls):
                completion(paywalls.paywalls, paywalls.products, nil)
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
    
    func signSubscriptionOffer(params: Parameters, completion: @escaping JSONCompletion) {
        RequestManager.request(router: Router.signSubscriptionOffer(params: params)) { (result: Result<JSONAttributedModel, Error>, response) in
            switch result {
            case .success(let response):
                completion(response.data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func getPurchaserInfo(id: String, completion: @escaping PurchaserCompletion) {
        RequestManager.request(router: Router.getPurchaserInfo(id: id)) { (result: Result<PurchaserInfoModel, Error>, response) in
            switch result {
            case .success(let purchaserInfo):
                completion(purchaserInfo, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func updateAttribution(id: String, params: Parameters, completion: @escaping JSONCompletion) {
        RequestManager.request(router: Router.updateAttribution(id: id, params: params)) { (result: Result<JSONModel, Error>, response) in
            switch result {
            case .success(let response):
                completion(response.data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func getPromo(id: String, completion: @escaping PromoCompletion) {
        RequestManager.request(router: Router.getPromo(id: id)) { (result: Result<PromoModel, Error>, response) in
            switch result {
            case .success(let promo):
                completion(promo, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}
