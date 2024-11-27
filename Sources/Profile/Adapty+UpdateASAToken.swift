//
//  Adapty+UpdateASAToken.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation
#if !ADAPTY_KIDS_MODE && canImport(AdServices)
    import AdServices

    private let log = Log.default

    extension Adapty {
        func updateASATokenIfNeed(for profile: VH<AdaptyProfile>) {
            guard
                #available(iOS 14.3, macOS 11.1, visionOS 1.0, *),
                profileStorage.appleSearchAdsSyncDate == nil, // check if this is an actual first sync
                let attributionToken = try? Adapty.getASAToken()
            else { return }

            Task {
                let profileId = profile.value.profileId

                let response = try await httpSession.sendASAToken(
                    profileId: profileId,
                    token: attributionToken,
                    responseHash: profile.hash
                )

                if let profile = response.flatValue() {
                    profileManager?.saveResponse(profile)
                }

                if profileStorage.profileId == profileId {
                    // mark appleSearchAds attribution data as synced
                    profileStorage.setAppleSearchAdsSyncDate()
                }
            }
        }

        @available(iOS 14.3, macOS 11.1, visionOS 1.0, *)
        static func getASAToken() throws -> String {
            let stamp = Log.stamp
            Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .fetchASAToken,
                stamp: stamp
            ))

            do {
                let attributionToken = try AAAttribution.attributionToken()

                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .fetchASAToken,
                    stamp: stamp,
                    params: [
                        "token": attributionToken,
                    ]
                ))

                return attributionToken

            } catch {
                log.error("UpdateASAToken: On AAAttribution.attributionToken \(error)")
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .fetchASAToken,
                    stamp: stamp,
                    error: "\(error.localizedDescription). Detail: \(error)"
                ))
                throw error
            }
        }
    }

#else
    extension Adapty {
        func updateASATokenIfNeed(for _: VH<AdaptyProfile>) {}
    }
#endif
