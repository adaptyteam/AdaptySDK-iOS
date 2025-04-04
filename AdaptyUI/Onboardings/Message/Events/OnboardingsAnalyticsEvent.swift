//
//  OnboardingsAnalyticsEvent.swift
//
//
//  Created by Aleksei Valiano on 01.08.2024
//
//

import Foundation

private let log = Log.Category(name: "AnalitycsEvent")

public enum OnboardingsAnalyticsEvent: Sendable, Hashable {
    case unknown(meta: OnboardingsMetaParams, name: String)
    case onboardingStarted(meta: OnboardingsMetaParams)
    case screenPresented(meta: OnboardingsMetaParams)
    case screenCompleted(meta: OnboardingsMetaParams, elementId: String?, reply: String?)
    case secondScreenPresented(meta: OnboardingsMetaParams)
    case registrationScreenPresented(meta: OnboardingsMetaParams)
    case productsScreenPresented(meta: OnboardingsMetaParams)
    case userEmailCollected(meta: OnboardingsMetaParams)
    case onboardingCompleted(meta: OnboardingsMetaParams)

    public var meta: OnboardingsMetaParams {
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
        let meta = try OnboardingsMetaParams(body["meta"])

        let name = try body["name"].asString()
        let params = try body["params"].asOptionalDictionary()

        guard let name = Name(rawValue: name) else {
            self = .unknown(meta: meta, name: name)
            log.warn("Uncnown analitycs event with name: \(name), meta: \(meta.debugDescription)")
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

extension OnboardingsAnalyticsEvent: CustomDebugStringConvertible {
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
