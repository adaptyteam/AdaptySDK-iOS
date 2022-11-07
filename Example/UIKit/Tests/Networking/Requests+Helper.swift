//
//  Requests+Helper.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

struct Tester {
    static func jsonDataNamed(_ name: String) throws -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Missing file named: \(name).json")
        }
        return try Data(contentsOf: url)
    }

    static func createBackendAndSession(id: String?, secretKey: String = TestsConstants.secretKey) -> (Backend, HTTPSession) {
        let backend = Backend(secretKey: secretKey)
        return (backend, backend.createHTTPSession(responseQueue: .main) { error in
            print("#BACKEND_\(id?.uppercased() ?? "UNKNOWN")# Error \(error)")
        })
    }

    static func getLatestReceipt() -> Data? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }

        var receipt: Data?
        do {
            receipt = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
        } catch {
        }

        return receipt
    }

    static func makeCreateProfileRequest(_ session: HTTPSession, profileId: String, completion: @escaping (Bool) -> Void) {
        let request = CreateProfileRequest(profileId: profileId, customerUserId: nil, parameters: nil, environmentMeta: Environment.Meta(includedAnalyticIds: true))
        session.perform(request) { (result: CreateProfileRequest.Result) in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    static func fetchKinesisCredentials(_ session: HTTPSession, profileId: String, completion: @escaping (Result<KinesisCredentials, HTTPError>) -> Void) {
        let request = FetchKinesisCredentialsRequest(profileId: profileId)
        session.perform(request) { (result: FetchKinesisCredentialsRequest.Result) in

            switch result {
            case let .success(response):
                completion(.success(response.body.value))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
