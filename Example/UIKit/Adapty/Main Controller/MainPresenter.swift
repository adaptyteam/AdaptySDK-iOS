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

class MainPresenter: ObservableObject {
    enum Item {
        case customerUserId(String?)
        case updateUserId

        case getPurchaserInfoResult(PurchaserInfoModel?)
        case getPurchaserInfo
        
        case showPaywall
        
        case updateAttribution
        case updateProfile

        case logout
        case lastError(Error?)
    }

    private var cancellable = Set<AnyCancellable>()

    @Published var items = [Item]()

    init() {
        PurchasesObserver.shared.$purchaserInfo
            .sink(receiveValue: { [weak self] v in
                self?.purchaserInfo = v
            })
            .store(in: &cancellable)
    }

    private var purchaserInfo: PurchaserInfoModel? {
        didSet {
            reloadData()
        }
    }

    private var lastError: Error? {
        didSet {
            reloadData()
        }
    }

    func reloadData() {
        items = [
            .customerUserId(Adapty.customerUserId),
            .updateUserId,
            .getPurchaserInfoResult(purchaserInfo),
            .getPurchaserInfo,
            .showPaywall,
            .updateProfile,
            .updateAttribution,
            .logout,
            .lastError(lastError),
        ]
    }

    func identifyUser(_ userId: String) {
        Adapty.identify(userId) { [weak self] error in
            if let error = error {
                self?.lastError = error
            }

            self?.reloadData()
        }
    }

    func getPurchaserInfo() {
        Adapty.getPurchaserInfo { [weak self] purchaserInfo, error in
            if let error = error {
                self?.lastError = error
            } else {
                self?.purchaserInfo = purchaserInfo
            }
        }
    }

    func updateAttribution() {
        let attribution = ["trackerToken": "test_trackerToken", "trackerName": "test_trackerName", "network": "test_network", "campaign": "test_campaign", "adgroup": "test_adgroup", "creative": "test_creative", "clickLabel": "test_clickLabel", "adid": "test_adid"]
        Adapty.updateAttribution(attribution, source: .adjust) { [weak self] error in
            if let error = error {
                self?.lastError = error
            }
        }
    }

    func updateProfileAttributes() {
        var params =
            ProfileParameterBuilder().withEmail("email@email.com").withPhoneNumber("+78888888888").withFacebookUserId("facebookUserId-test").withAmplitudeUserId("amplitudeUserId-test").withAmplitudeDeviceId("amplitudeDeviceId-test").withMixpanelUserId("mixpanelUserId-test").withAppmetricaProfileId("appmetricaProfileId-test").withAppmetricaDeviceId("appmetricaDeviceId-test").withFirstName("First Name").withLastName("Last Name").withGender(.other).withBirthday(Date()).withCustomAttributes(["key1": "value1", "key2": "value2"]).withFacebookAnonymousId("facebookAnonymousId-test")

        if #available(iOS 14, macOS 11.0, *) {
            params = params.withAppTrackingTransparencyStatus(.authorized)
        }

        Adapty.updateProfile(params: params) { [weak self] error in
            if let error = error {
                self?.lastError = error
            }
        }
    }

    func logout() {
        Adapty.logout { [weak self] error in
            if let error = error {
                self?.lastError = error
            } else {
                self?.reloadData()
            }
        }
    }
}
