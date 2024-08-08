//
//  MainViewModel.swift
//  AdaptyRecipes-UIKit
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Adapty
import Combine
import Foundation

extension MainViewModel {
    static let shared = MainViewModel()
    
    var isPremiumUser: Bool { profile?.accessLevels[AppConstants.accessLevelId]?.isActive ?? false }
    var accessLevel: AdaptyProfile.AccessLevel? { profile?.accessLevels[AppConstants.accessLevelId] }
}

class MainViewModel: NSObject, ObservableObject, AdaptyDelegate {
    override init() {
        super.init()
        
        userId = UserManager.currentUserId
    }
    
    // MARK: Profile
    
    @Published var profile: AdaptyProfile?
    @Published var getProfileInProgress = false
    
    @MainActor
    func reloadProfile() async {
        do {
            getProfileInProgress = true
            profile = try await Adapty.getProfile()
        } catch {
            Logger.log(.error, "reloadProfile: \(error)")
        }
        
        getProfileInProgress = false
    }
    
    // MARK: Login and Logout
    
    @Published var userId: String?
    
    func login(to userId: String) {
        Task {
            await MainActor.run {
                UserManager.login(to: userId)
                self.userId = userId
            }
            
            do {
                try await Adapty.identify(userId)
            } catch {
                Logger.log(.error, "login: \(error)")
            }
        }
    }
    
    func logout() {
        Task {
            await MainActor.run {
                UserManager.logout()
                self.userId = nil
            }
            
            do {
                try await Adapty.logout()
            } catch {
                Logger.log(.error, "logout: \(error)")
            }
        }
    }
        
    // MARK: Purchases
    
    @MainActor
    func restorePurchases() async {
        do {
            profile = try await Adapty.restorePurchases()
        } catch {
            Logger.log(.error, "logout: \(error)")
        }
    }
    
    // MARK: AdaptyDelegate
    
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        self.profile = profile
    }
}
