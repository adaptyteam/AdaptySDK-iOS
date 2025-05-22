//
//  OnboardingsMessage+Decoder.swift
//
//
//  Created by Aleksei Valiano on 07.08.2024
//
//

import Foundation

extension AdaptyOnboardingsMessage {
    init(chanel: String, body: Any) throws {
//        enum ChanelName: String {
//            case events
//        }
//
//        switch ChanelName(rawValue: chanel) {
//        case .none:
//            let body = try? BodyDecoder.decode(body).asOptionalDictionary()
//            let type = try? body?["type"].asOptionalString()
//            throw Onboardings.UnknownEventError(chanel: chanel, type: type)
//        case .events:
        try self.init(chanel, eventBody: body)
//        }
    }

    enum TypeName: String {
        case close
        case openPaywall = "open_paywall"
        case custom
        case stateUpdated = "state_updated"
        case analytics
        case didFinishLoading = "onboarding_loaded"
    }

    private init(_ chanel: String, eventBody body: Any) throws {
        let body = try BodyDecoder.decode(body).asDictionary()
        let type = try body["type"].asString()

        switch TypeName(rawValue: type) {
        case .none:
            throw OnboardingsUnknownMessageError(chanel: chanel, type: type)
        case .analytics:
            self = try .analytics(.init(body))
        case .stateUpdated:
            self = try .stateUpdated(.init(body))
        case .close:
            self = try .close(.init(body))
        case .openPaywall:
            self = try .openPaywall(.init(body))
        case .custom:
            self = try .custom(.init(body))
        case .didFinishLoading:
            self = try .didFinishLoading(.init(body))

        }
    }
}
