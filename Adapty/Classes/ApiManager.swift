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
public typealias PurchaseContainersCompletion = ([PurchaseContainerModel]?, [ProductModel]?, Error?) -> Void
public typealias ValidateReceiptCompletion = (PurchaserInfoModel?, Parameters?, Error?) -> Void
public typealias JSONCompletion = (Parameters?, Error?) -> Void
public typealias ErrorCompletion = (Error?) -> Void
public typealias PurchaserCompletion = (PurchaserInfoModel?, Error?) -> Void
public typealias CahcedPurchaserCompletion = (PurchaserInfoModel?, DataState, Error?) -> Void

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
    
    func getPurchaseContainers(params: Parameters, completion: @escaping PurchaseContainersCompletion) {
        RequestManager.request(router: Router.getPurchaseContainers(params: params)) { (result: Result<PurchaseContainersArray, Error>, response) in
            switch result {
            case .success(let containers):
                completion(containers.containers, containers.products, nil)
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
    
}
