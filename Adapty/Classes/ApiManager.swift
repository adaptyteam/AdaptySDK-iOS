//
//  ApiManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
//

import Foundation

public typealias ProfileCreateCompletion = (ProfileModel?, Error?, Bool?) -> Void
public typealias ProfileCompletion = (ProfileModel?, Error?) -> Void
public typealias InstallationCompletion = (InstallationModel?, Error?) -> Void
public typealias JSONCompletion = (Parameters?, Error?) -> Void
public typealias ErrorCompletion = (Error?) -> Void

class ApiManager {
    
    func createProfile(params: Parameters, completion: @escaping ProfileCreateCompletion) {
        RequestManager.request(router: Router.createProfile(params)) { (result: Result<ProfileModel, Error>, response) in
            switch result {
            case .success(let profile):
                completion(profile, nil, response?.statusCode == 201 ? true : false)
            case .failure(let error):
                completion(nil, error, nil)
            }
        }
    }
    
    func updateProfile(id: String, params: Parameters, completion: @escaping ProfileCompletion) {
        RequestManager.request(router: Router.updateProfile(id: id, params: params)) { (result: Result<ProfileModel, Error>, response) in
            switch result {
            case .success(let profile):
                completion(profile, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func createInstallation(params: Parameters, completion: @escaping InstallationCompletion) {
        RequestManager.request(router: Router.createInstallation(params: params)) { (result: Result<InstallationModel, Error>, response) in
            switch result {
            case .success(let installation):
                completion(installation, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func updateInstallation(id: String, params: Parameters, completion: @escaping InstallationCompletion) {
        RequestManager.request(router: Router.updateInstallation(id: id, params: params)) { (result: Result<InstallationModel, Error>, response) in
            switch result {
            case .success(let installation):
                completion(installation, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func validateReceipt(params: Parameters, completion: @escaping JSONCompletion) {
        RequestManager.request(router: Router.validateReceipt(params: params)) { (result: Result<JSONModel, Error>, response) in
            switch result {
            case .success(let response):
                completion(response.data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}
