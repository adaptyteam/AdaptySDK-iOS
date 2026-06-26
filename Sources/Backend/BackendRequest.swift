//
//  BackendRequest.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 11.11.2025.
//

protocol BackendRequest: Sendable, HTTPRequest {
    var stamp: String { get }
    var requestName: BackendRequestName { get }
    var logParams: EventParameters? { get }
}

extension BackendRequest {
    var logParams: EventParameters? {
        nil
    }
}

protocol BackendEncodableRequest: BackendRequest, HTTPEncodableRequest {}

enum BackendRequestName: String {
    case fetchProductStates = "get_products"
    case fetchAllProductInfo = "get_all_products_info"

    case sendEvents = "send_events"

    case createProfile = "create_profile"
    case fetchProfile = "get_profile"
    case updateProfile = "update_profile"

    case fetchCrossPlacementState = "get_cross_placement_state"

    case fetchFlow = "get_flow"
    case fetchFlowVariations = "get_flow_variations"
    case fetchFlowForDefaultAudience = "get_flow_default_audience"
    case fetchFlowVariationsForDefaultAudience = "get_flow_variations_default_audience"

    case fetchOnboarding = "get_onboarding"
    case fetchOnboardingVariations = "get_onboarding_variations"
    case fetchOnbordingForDefaultAudience = "get_onbording_default_audience"
    case fetchOnboardingVariationsForDefaultAudience = "get_onboarding_variations_default_audience"

    case fetchUISchema = "get_ui_schema"
    case fetchFallBackUISchema = "get_fallback_ui_schema"

    case validateTransaction = "validate_transaction"
    case validateReceipt = "validate_receipt"

    case sendASAToken = "set_asa_token"
    case setAttributionData = "set_attribution_data"
    case setIntegrationIdentifier = "set_integration_identifier"
    case signSubscriptionOffer = "sign_offer"

    case fetchNetworkConfig = "get_net_config"

    case reqisterInstall = "reqister_install"
}
