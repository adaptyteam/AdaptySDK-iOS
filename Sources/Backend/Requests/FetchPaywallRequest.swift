//
//  FetchPaywallRequest.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.09.2022.
//

import Foundation

struct FetchPaywallRequest: HTTPRequestWithDecodableResponse {
    typealias ResponseBody = Backend.Response.Body<AdaptyPaywall?>

    let endpoint: HTTPEndpoint
    let headers: Headers
    let queryItems: QueryItems

    func getDecoder(_ jsonDecoder: JSONDecoder) -> ((HTTPDataResponse) -> HTTPResponse<ResponseBody>.Result) {
        { response in
            let result: Result<AdaptyPaywall?, Error>

            if headers.hasSameBackendResponseHash(response.headers) {
                result = .success(nil)
            } else {
                result = jsonDecoder.decode(Backend.Response.Body<AdaptyPaywall>.self, response.body).map { $0.value }
            }
            return result.map { response.replaceBody(Backend.Response.Body($0)) }
                .mapError { .decoding(response, error: $0) }
        }
    }

    init(paywallId: String, locale: String?, profileId: String, responseHash: String?) {
        endpoint = HTTPEndpoint(
            method: .get,
            path: "/sdk/in-apps/purchase-containers/\(paywallId)/"
        )

        headers = Headers()
            .setBackendProfileId(profileId)
            .setBackendResponseHash(responseHash)

        queryItems = QueryItems()
            .setLocale(locale)
            .setBackendProfileId(profileId)
    }
}

extension HTTPSession {
    func performFetchPaywallRequest(paywallId: String,
                                    locale: String?,
                                    profileId: String,
                                    responseHash: String?,
                                    syncedBundleReceipt: Bool,
                                    _ completion: @escaping AdaptyResultCompletion<VH<AdaptyPaywall?>>) {
        let request = FetchPaywallRequest(paywallId: paywallId,
                                          locale: locale,
                                          profileId: profileId,
                                          responseHash: responseHash)
        perform(request, logName: "get_paywall") { (result: FetchPaywallRequest.Result) in
            switch result {
            case let .failure(error):
                completion(.failure(error.asAdaptyError))
            case let .success(response):
                var paywall = response.body.value
                var hash = response.headers.getBackendResponseHash()
                if !syncedBundleReceipt {
                    paywall = paywall?.map(syncedBundleReceipt: false)
                    if paywall?.products.contains(where: { $0.introductoryOfferEligibility == .unknown }) ?? false {
                        hash = nil
                    }
                }
                completion(.success(VH(paywall, hash: hash)))
            }
        }
    }
}
