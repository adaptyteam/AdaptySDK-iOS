//
//  StoreMessageControlTests.swift
//  AdaptyTests
//

#if (os(iOS) || os(visionOS)) && canImport(UIKit)

@testable import Adapty
import Foundation
import StoreKit
import Testing

@Suite(
    "StoreMessages Tests",
    .serialized,
    .component("StoreMessages"),
    .owner("Aleksei Valiano")
)
enum StoreMessagesTests {
    @Suite("StoreMessagesHandling Configuration")
    struct StoreMessagesHandlingConfigurationTests {
        /// A configuration is built without an explicit handling override. The resulting mode is `auto`.
        @Test("Default configuration uses automatic mode")
        func defaultConfigurationUsesAutomaticMode() {
            let configuration = AdaptyConfiguration.builder(
                withAPIKey: "public_live_0000000000000000000000000000000000000000"
            ).build()

            #expect(AdaptyConfiguration.StoreMessagesHandling.default == .auto)
            #expect(configuration.storeMessagesHandling == .auto)
        }

        /// Each supported handling mode is passed to the builder. The built configuration preserves the selected mode.
        @Test("Explicit configuration uses selected mode", arguments: [
            AdaptyConfiguration.StoreMessagesHandling.default,
            AdaptyConfiguration.StoreMessagesHandling.auto,
            AdaptyConfiguration.StoreMessagesHandling.manual,
        ])
        func explicitConfigurationUsesSelectedMode(
            mode: AdaptyConfiguration.StoreMessagesHandling
        ) {
            let configuration = AdaptyConfiguration.builder(
                withAPIKey: "public_live_0000000000000000000000000000000000000000"
            )
            .with(storeMessagesHandling: mode)
            .build()

            #expect(configuration.storeMessagesHandling == mode)
        }

        /// Each handling mode is encoded. `default` and `auto` produce `"auto"`, while `manual` produces `"manual"`.
        @Test("Handling modes encode to canonical JSON values", arguments: [
            (mode: AdaptyConfiguration.StoreMessagesHandling.default, json: Json(#""auto""#)),
            (mode: AdaptyConfiguration.StoreMessagesHandling.auto, json: Json(#""auto""#)),
            (mode: AdaptyConfiguration.StoreMessagesHandling.manual, json: Json(#""manual""#)),
        ])
        func handlingModesEncodeToCanonicalJSONValues(
            mode: AdaptyConfiguration.StoreMessagesHandling,
            json: Json
        ) throws {
            let encoded = try Json.encode(mode)

            #expect(encoded == json)
        }

        /// The `default`, `auto`, and `manual` JSON strings are decoded. Each produces the matching mode, with `default` resolving to automatic handling.
        @Test("Supported JSON values decode to handling modes", arguments: [
            (json: Json(#""default""#), mode: AdaptyConfiguration.StoreMessagesHandling.default),
            (json: Json(#""auto""#), mode: AdaptyConfiguration.StoreMessagesHandling.auto),
            (json: Json(#""manual""#), mode: AdaptyConfiguration.StoreMessagesHandling.manual),
        ])
        func supportedJSONValuesDecodeToHandlingModes(
            json: Json,
            mode: AdaptyConfiguration.StoreMessagesHandling
        ) throws {
            let decoded = try json.decode(AdaptyConfiguration.StoreMessagesHandling.self)

            #expect(decoded == mode)
        }
    }

    @Suite("AdaptyStoreMessageType Serialization")
    struct AdaptyStoreMessageTypeRawValueTests {
        /// Each public message category is read. Its raw value matches the stable client and telemetry contract.
        @Test("Known message types use stable raw values", arguments: [
            (messageType: AdaptyStoreMessageType.generic, string: "generic"),
            (messageType: AdaptyStoreMessageType.priceIncreaseConsent, string: "price_increase_consent"),
            (messageType: AdaptyStoreMessageType.billingIssue, string: "billing_issue"),
            (messageType: AdaptyStoreMessageType.winBackOffer, string: "win_back_offer"),
        ])
        func knownMessageTypesUseStableRawValues(
            messageType: AdaptyStoreMessageType,
            string: String
        ) {
            #expect(messageType.rawValue == string)
        }
    }

    @Suite("StoreKit Reason to AdaptyStoreMessageType Mapping")
    struct StoreKitReasonToAdaptyTypeMappingTests {
        /// A baseline StoreKit reason is converted on iOS 16 or newer. The result is the matching `AdaptyStoreMessageType`.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("StoreKit(16.0+) reasons map to AdaptyStoreMessageType", arguments: [
            (reason: StoreKit.Message.Reason.generic, messageType: AdaptyStoreMessageType.generic),
            (reason: StoreKit.Message.Reason.priceIncreaseConsent, messageType: AdaptyStoreMessageType.priceIncreaseConsent),
        ])
        func storeKitReasonsMapToAdaptyStoreMessageTypeios_16_0(
            reason: StoreKit.Message.Reason,
            messageType: AdaptyStoreMessageType
        ) {
            #expect(AdaptyStoreMessageType(reason) == messageType)
        }

        /// The StoreKit billing-issue reason is converted on iOS 16.4 or newer. The result is `billingIssue`.
        @available(iOS 16.4, macCatalyst 16.4, visionOS 1.0, *)
        @Test("StoreKit(iOS 16.4+) reasons map to AdaptyStoreMessageType", arguments: [
            (reason: StoreKit.Message.Reason.billingIssue, messageType: AdaptyStoreMessageType.billingIssue)
        ])
        func storeKitReasonsMapToAdaptyStoreMessageType_ios16_4(
            reason: StoreKit.Message.Reason,
            messageType: AdaptyStoreMessageType
        ) {
            #expect(AdaptyStoreMessageType(reason) == messageType)
        }

        /// The StoreKit win-back-offer reason is converted on iOS 18 or newer. The result is `winBackOffer`.
        @available(iOS 18.0, macCatalyst 18.0, visionOS 2.0, *)
        @Test("StoreKit(iOS 18.0+) reasons map to AdaptyStoreMessageType", arguments: [
            (reason: StoreKit.Message.Reason.winBackOffer, messageType: AdaptyStoreMessageType.winBackOffer)
        ])
        func storeKitReasonsMapToAdaptyStoreMessageType_ios18_0(
            reason: StoreKit.Message.Reason,
            messageType: AdaptyStoreMessageType
        ) {
            #expect(AdaptyStoreMessageType(reason) == messageType)
        }

        /// A StoreKit reason unknown to this SDK version is converted. Its `AdaptyStoreMessageType` preserves the numeric value losslessly.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Unknown StoreKit reasons map losslessly to AdaptyStoreMessageType", arguments: [
            (skReasonValue: 12345, messageTypeValue: "storekit_12345"),
            (skReasonValue: 67890, messageTypeValue: "storekit_67890")
        ])
        func unknownStoreKitReasonsMapLosslesslyToAdaptyStoreMessageType(
            skReasonValue: Int,
            messageTypeValue: String
        ) {
            let unknownReason = StoreKit.Message.Reason(rawValue: skReasonValue)

            #expect(AdaptyStoreMessageType(unknownReason).rawValue == messageTypeValue)
        }
    }

    @Suite("StoreMessages Errors to AdaptyErrorCode Mapping")
    struct StoreMessagesErrorToAdaptyErrorCodeMappingTests {
        /// A StoreMessages scene-resolution or concurrent-show error is created.
        /// It maps to the expected generic Adapty error code and numeric value while preserving its StoreMessages-specific diagnostic description.
        @Test("StoreMessages errors map to generic codes", arguments: [
            (
                expectedAdaptyErrorCode: AdaptyError.ErrorCode.operationInProgress,
                expectedErrorCode: 3201,
                expectedDescription: "Another store message show operation is already in progress."
            ),
            (
                expectedAdaptyErrorCode: AdaptyError.ErrorCode.resolverFailure,
                expectedErrorCode: 3202,
                expectedDescription: "No foreground-active UIWindowScene is available to display store messages."
            ),
        ])
        func storeMessagesErrorsMapToGenericCodes(
            expectedAdaptyErrorCode: AdaptyError.ErrorCode,
            expectedErrorCode: Int,
            expectedDescription: String
        ) {
            let error: AdaptyError
            switch expectedAdaptyErrorCode {
            case .operationInProgress:
                error = AdaptyError.storeMessageShowInProgress()
            case .resolverFailure:
                error = AdaptyError.storeMessageSceneUnavailable()
            default:
                Issue.record("Unexpected error code: \(expectedAdaptyErrorCode)")
                return
            }

            #expect(error.adaptyErrorCode == expectedAdaptyErrorCode)
            #expect(error.errorCode == expectedErrorCode)
            #expect(error.errorUserInfo[AdaptyError.UserInfoKey.description] as? String == expectedDescription)
        }
    }

    @Suite("Pending Store Message Type Retrieval")
    struct PendingStoreMessageTypeRetrievalTests {
        /// `getPendingStoreMessageTypes()` is called before a message manager exists. The returned snapshot is empty.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Missing manager returns empty snapshot")
        func missingManagerReturnsEmptySnapshot() async {
            #expect(await Adapty.getPendingStoreMessageTypes().isEmpty)
        }
    }

    @Suite("Store Message Presentation No-Op Paths")
    struct StoreMessagePresentationNoOpPathTests {
        /// A message presentation is requested before a manager exists. The async API completes without an error.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Missing manager makes presentation a no-op")
        func missingManagerMakesPresentationANoOp() async throws {
            try await Adapty.showStoreMessages(for: [.generic])
        }

        /// The caller task is cancelled before a presentation with no pending messages. The no-op path still completes successfully.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Cancelled empty presentation still succeeds")
        func cancelledEmptyPresentationStillSucceeds() async throws {
            let show = Task {
                withUnsafeCurrentTask { task in
                    task?.cancel()
                }
                try await Adapty.showStoreMessages(for: [.generic])
            }

            _ = try await show.value
        }
    }

    @Suite("Pending Store Message Type Callback Dispatch")
    struct PendingStoreMessageTypeCallbackDispatchTests {
        /// The snapshot completion API uses the default callback configuration. It returns an empty result on the main queue.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Default callback returns empty snapshot on main queue")
        func defaultCallbackReturnsEmptySnapshotOnMainQueue() async {
            let result = await withCheckedContinuation { continuation in
                Adapty.getPendingStoreMessageTypes { types in
                    continuation.resume(returning: (types, Thread.isMainThread))
                }
            }

            #expect(result.0.isEmpty)
            #expect(result.1)
        }
    }

    @Suite("Store Message Presentation Callback Dispatch")
    struct StoreMessagePresentationCallbackDispatchTests {
        /// The show completion API uses the default callback configuration. It returns success on the main queue.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Default callback returns success on main queue")
        func defaultCallbackReturnsSuccessOnMainQueue() async {
            let result = await withCheckedContinuation { continuation in
                Adapty.showStoreMessages(for: [.generic]) { error in
                    continuation.resume(returning: (error, Thread.isMainThread))
                }
            }

            #expect(result.0 == nil)
            #expect(result.1)
        }

        /// A custom callback queue is configured before a no-op show. Exactly one successful completion runs on that queue.
        @available(iOS 16.0, macCatalyst 16.0, visionOS 1.0, *)
        @Test("Configured callback runs once on selected queue")
        @AdaptyActor
        func configuredCallbackRunsOnceOnSelectedQueue() async {
            let callbackQueue = DispatchQueue(label: "io.adapty.tests.store-message-callback")
            let callbackQueueKey = DispatchSpecificKey<Bool>()
            callbackQueue.setSpecific(key: callbackQueueKey, value: true)
            AdaptyConfiguration.callbackDispatchQueue = callbackQueue
            defer { AdaptyConfiguration.callbackDispatchQueue = nil }

            await confirmation("Completion runs exactly once", expectedCount: 1) { completion in
                let result = await withCheckedContinuation { continuation in
                    Adapty.showStoreMessages { error in
                        completion()
                        continuation.resume(returning: (
                            error,
                            DispatchQueue.getSpecific(key: callbackQueueKey) == true
                        ))
                    }
                }

                #expect(result.0 == nil)
                #expect(result.1)
            }
        }
    }
}

#endif
