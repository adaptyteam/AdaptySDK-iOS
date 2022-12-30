//
//  MainPresenter.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 16.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Combine
import Foundation

struct AdaptyIdentifiableError: Identifiable {
    let id: String = UUID().uuidString
    let error: AdaptyError
}

class MainPresenter: ObservableObject {
    private var cancellable = Set<AnyCancellable>()

    @Published var adaptyId: String?

    @Published var customerUserId: String = ""
    @Published var customerUserIdEdited: String = ""

    @Published var profileCollapsed = true
    @Published var profile: AdaptyProfile? {
        didSet {
            adaptyId = profile?.profileId
        }
    }

    @Published var exampleABTestPaywall: AdaptyPaywall?
    @Published var exampleABTestProducts: [AdaptyPaywallProduct]?
    @Published var errors: [AdaptyIdentifiableError] = []

    init() {
        customerUserId = ""
        customerUserIdEdited = ""

        PurchasesObserver.shared.$profile
            .sink(receiveValue: { [weak self] v in
                self?.profile = v
            })
            .store(in: &cancellable)

        PurchasesObserver.shared.$paywall
            .sink(receiveValue: { [weak self] v in
                self?.exampleABTestPaywall = v
            })
            .store(in: &cancellable)

        PurchasesObserver.shared.$products
            .sink(receiveValue: { [weak self] v in
                self?.exampleABTestProducts = v
            })
            .store(in: &cancellable)
    }

    func identifyUser(_ userId: String) {
        Adapty.identify(userId) { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            } else {
                self?.customerUserId = userId
                self?.customerUserIdEdited = userId
            }
        }
    }

    @Published var getProfileInProgress = false

    func getProfile() {
        getProfileInProgress = true

        Adapty.getProfile { [weak self] result in
            self?.getProfileInProgress = false

            switch result {
            case let .failure(error):
                self?.errors.append(AdaptyIdentifiableError(error: error))
            case let .success(profile):
                self?.profile = profile
            }
        }
    }

    @Published var customPaywall: AdaptyPaywall? {
        didSet {
            reloadCustomPaywallProducts()
        }
    }
    @Published var customPaywallProducts: [AdaptyPaywallProduct]?
    @Published var customPaywallId: String = ""
    @Published var customPaywallCollapsed: Bool = true

    func reloadCustomPaywall() {
        guard !customPaywallId.isEmpty else { return }

        Adapty.getPaywall(customPaywallId) { [weak self] result in
            switch result {
            case let .failure(error):
                self?.errors.append(AdaptyIdentifiableError(error: error))
            case let .success(paywall):
                self?.customPaywall = paywall
            }
        }
    }
    
    private func reloadCustomPaywallProducts() {
        guard let customPaywall = customPaywall else { return }
        
        Adapty.getPaywallProducts(paywall: customPaywall) { [weak self] result in
            self?.customPaywallProducts = try? result.get()
            self?.customPaywallCollapsed = false
        }
    }

    func purchaseProduct(product: AdaptyPaywallProduct) {
        PurchasesObserver.shared.makePurchase(product, completion: { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            }
        })
    }
    
    func restorePurchases() {
        PurchasesObserver.shared.restore { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            }
        }
    }

    func updateAttribution() {
        let attribution = ["trackerToken": "test_trackerToken", "trackerName": "test_trackerName", "network": "test_network", "campaign": "test_campaign", "adgroup": "test_adgroup", "creative": "test_creative", "clickLabel": "test_clickLabel", "adid": "test_adid"]
        Adapty.updateAttribution(attribution, source: .adjust) { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            }
        }
    }

    func updateProfileAttributes() throws {
        let builder = try AdaptyProfileParameters.Builder()
            .with(email: "email@email.com")
            .with(phoneNumber: "+78888888888")
//            .with(facebookUserId: "facebookUserId-test")
            .with(amplitudeUserId: "amplitudeUserId-test")
            .with(amplitudeDeviceId: "amplitudeDeviceId-test")
            .with(mixpanelUserId: "mixpanelUserId-test")
            .with(appmetricaProfileId: "appmetricaProfileId-test")
            .with(appmetricaDeviceId: "appmetricaDeviceId-test")
            .with(firstName: "First Name")
            .with(lastName: "Last Name")
            .with(gender: .other)
            .with(birthday: Date())
            .with(customAttribute: "value1", forKey: "key1")
            .with(customAttribute: "value2", forKey: "key2")
            .with(facebookAnonymousId: "facebookAnonymousId-test")

        if #available(iOS 14, macOS 11.0, *) {
            builder.with(appTrackingTransparencyStatus: .authorized)
        }

        Adapty.updateProfile(params: builder.build()) { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            }
        }
    }

    func sendOnboardingEvent(name: String, order: UInt) {
        Adapty.logShowOnboarding(name: "test_onboarding", screenName: name, screenOrder: order) { [weak self] error in
            if let error = error {
                self?.errors.append(AdaptyIdentifiableError(error: error))
            }
        }
    }
    
    func presentCodeRedemptionSheet() {
        Adapty.presentCodeRedemptionSheet()
    }

    @Published var isLoggingOut = false

//    func setEnvironment(_ env: AdaptyEnvironment) {
//        guard env != AppEnvironment.selectedEnvironment else { return }
//
//        isLoggingOut = true
//
//        AppEnvironment.selectedEnvironment = env
//
//        Adapty.logout { [weak self] error in
//            self?.isLoggingOut = false
//
//            if let error = error {
//                self?.errors.append(AdaptyIdentifiableError(error: error))
//            } else {
//                self?.customerUserId = ""
//                self?.customerUserIdEdited = ""
//            }
//        }
//    }

    func logout() {
        isLoggingOut = true

        Adapty.logout { [weak self] error in
            guard let self = self else { return }
            
            self.isLoggingOut = false

            if let error = error {
                self.errors.append(AdaptyIdentifiableError(error: error))
            } else {
                self.customerUserId = ""
                self.customerUserIdEdited = ""
                
                self.customPaywall = nil
                self.customPaywallProducts = nil
                self.customPaywallId = ""
                self.customPaywallCollapsed = true
                
                PurchasesObserver.shared.loadInitialProfileData()
                PurchasesObserver.shared.loadInitialPaywallData()
            }
        }
    }
}
