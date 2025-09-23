//
//  AdaptyOnboardingsAnalyticsEvent.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Adapty
import Foundation

public enum AdaptyOnboardingsAnalyticsEvent: Sendable, Hashable {
    case unknown(meta: AdaptyOnboardingsMetaParams, name: String)
    case onboardingStarted(meta: AdaptyOnboardingsMetaParams)
    case screenPresented(meta: AdaptyOnboardingsMetaParams)
    case screenCompleted(meta: AdaptyOnboardingsMetaParams, elementId: String?, reply: String?)
    case secondScreenPresented(meta: AdaptyOnboardingsMetaParams)
    case registrationScreenPresented(meta: AdaptyOnboardingsMetaParams)
    case productsScreenPresented(meta: AdaptyOnboardingsMetaParams)
    case userEmailCollected(meta: AdaptyOnboardingsMetaParams)
    case onboardingCompleted(meta: AdaptyOnboardingsMetaParams)

    public var meta: AdaptyOnboardingsMetaParams {
        switch self {
        case let .unknown(meta, _),
             let .onboardingStarted(meta),
             let .screenPresented(meta),
             let .screenCompleted(meta, _, _),
             let .secondScreenPresented(meta),
             let .registrationScreenPresented(meta),
             let .productsScreenPresented(meta),
             let .userEmailCollected(meta),
             let .onboardingCompleted(meta):
            meta
        }
    }

    private enum Name: String, Sendable {
        case onboardingStarted = "onboarding_started"
        case screenPresented = "screen_presented"
        case screenCompleted = "screen_completed"
        case secondScreenPresented = "second_screen_presented"
        case registrationScreenPresented = "registration_screen_presented"
        case productsScreenPresented = "products_screen_presented"
        case userEmailCollected = "user_email_collected"
        case onboardingCompleted = "onboarding_completed"
    }

    init(_ body: BodyDecoder.Dictionary) throws {
        let meta = try AdaptyOnboardingsMetaParams(body["meta"])

        let name = try body["name"].asString()
        let params = try body["params"].asOptionalDictionary()

        guard let name = Name(rawValue: name) else {
            self = .unknown(meta: meta, name: name)
            Log.onboardings.warn("Unknown analitycs event with name: \(name), meta: \(meta.debugDescription)")
            return
        }

        self = switch name {
        case .onboardingStarted:
            .onboardingStarted(meta: meta)
        case .screenPresented:
            .screenPresented(meta: meta)
        case .screenCompleted:
            try .screenCompleted(
                meta: meta,
                elementId: params?["element_id"].asOptionalString(),
                reply: params?["reply"].asOptionalString()
            )
        case .secondScreenPresented:
            .secondScreenPresented(meta: meta)
        case .registrationScreenPresented:
            .registrationScreenPresented(meta: meta)
        case .productsScreenPresented:
            .productsScreenPresented(meta: meta)
        case .userEmailCollected:
            .userEmailCollected(meta: meta)
        case .onboardingCompleted:
            .onboardingCompleted(meta: meta)
        }
    }
}

extension AdaptyOnboardingsAnalyticsEvent: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .unknown(meta, name):
            "{name: \(name), meta: \(meta.debugDescription)}"
        case let .onboardingStarted(meta):
            "{name: \(Name.onboardingStarted.rawValue), meta: \(meta.debugDescription)}"
        case let .screenPresented(meta):
            "{name: \(Name.screenPresented.rawValue), meta: \(meta.debugDescription)}"
        case let .screenCompleted(meta, formClientId, reply):
            "{name: \(Name.screenCompleted.rawValue), formClientId: \(formClientId ?? "nil"), reply: \(reply ?? "nil"), meta: \(meta.debugDescription)}"
        case let .secondScreenPresented(meta):
            "{name: \(Name.secondScreenPresented.rawValue), meta: \(meta.debugDescription)}"
        case let .registrationScreenPresented(meta):
            "{name: \(Name.registrationScreenPresented.rawValue), meta: \(meta.debugDescription)}"
        case let .productsScreenPresented(meta):
            "{name: \(Name.productsScreenPresented.rawValue), meta: \(meta.debugDescription)}"
        case let .userEmailCollected(meta):
            "{name: \(Name.userEmailCollected.rawValue), meta: \(meta.debugDescription)}"
        case let .onboardingCompleted(meta):
            "{name: \(Name.onboardingCompleted.rawValue), meta: \(meta.debugDescription)}"
        }
    }
}
