//
//  Adapty+SyncIPv4.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 19.12.2023
//

import Foundation

extension Adapty {
    func syncIPv4IfNeed() {
        guard
            !Adapty.Configuration.ipAddressCollectionDisabled,
            Environment.Device.ipV4Address == nil
        else { return }

        fetchIPv4(afterMilliseconds: 0) { [weak self] ipV4Address in
            self?.send(ipV4Address: ipV4Address) { _ in }
        }
    }

    private func send(ipV4Address: String, _ completion: @escaping AdaptyErrorCompletion) {
        getProfileManager(waitCreatingProfile: false) { profileManager in
            guard let profileManager = try? profileManager.get() else {
                completion(profileManager.error)
                return
            }
            profileManager.updateProfile(params: AdaptyProfileParameters(ipV4Address: ipV4Address), completion)
        }
    }

    private func fetchIPv4(afterMilliseconds milliseconds: Int, _ completion: @escaping (String) -> Void) {
        let timeInterval = DispatchTimeInterval.milliseconds(min(milliseconds, 10000))

        Adapty.underlayQueue.asyncAfter(deadline: .now() + timeInterval) { [weak self] in

            if let value = Environment.Device.ipV4Address {
                completion(value)
                return
            }

            Adapty.fetchIPv4 { (result: Result<String, Error>) in
                Adapty.underlayQueue.async {
                    switch result {
                    case let .success(value):
                        Environment.Device.ipV4Address = value
                        completion(value)
                    case .failure:
                        self?.fetchIPv4(afterMilliseconds: milliseconds + 1000, completion)
                    }
                }
            }
        }
    }

    private static let fetchIPv4Url = URL(string: "https://api.ipify.org?format=json")!
    private struct FetchIPv4Response: Decodable {
        let ip: String
    }

    private static func fetchIPv4(completion: @escaping (Result<String, Error>) -> Void) {
        URLSession.shared.dataTask(with: fetchIPv4Url) { data, _, error in
            completion(error.map { .failure($0) } ?? JSONDecoder().decode(FetchIPv4Response.self, data).map { $0.ip })
        }.resume()
    }
}
