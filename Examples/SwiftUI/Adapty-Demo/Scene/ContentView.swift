//
//  ContentView.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import CryptoKit
import SwiftUI

struct ContentView: View {
    @Binding var showingPaywall: Bool
    @State var showingPremiumStuff: Bool = false
    @State var showingMenu: Bool = false
    @State var isLoading: Bool = false
    @State var alertMessage: String?
    @State var shouldShowAlert: Bool = false
    
    @State private var buttonImageName: String = Image.System.Name.locked
    
    @EnvironmentObject var userService: UserService
    @EnvironmentObject var paywallService: PaywallService
    
    // MARK: - body
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    Color.Palette.background.ignoresSafeArea()
                    VStack {
                        Spacer()
                        icon.padding()
                        Spacer()
                        button.isHidden(!userService.isLoggedIn)
                    }
                    .toolbar() {
                        ToolbarItem(placement: .navigationBarLeading) {
                            profileButton
                        }
                    }
                    .padding()
                    .disabled(isLoading)
                    progressView
                        .isHidden(!isLoading)
                }
                .navigationBarTitle("")
                .navigationBarHidden(false)
                .navigationBarTitleDisplayMode(.inline)
                
                
                premiumStuffView
            }
            .alert(alertMessage ?? "Error occurred", isPresented: $shouldShowAlert) {
                Button("OK", role: .cancel) {
                    alertMessage = nil
                    shouldShowAlert = false
                }
            }
        }
        .onChange(of: userService.isPremium) { isPremium in
            buttonImageName = isPremium ? Image.System.Name.unlocked : Image.System.Name.locked
        }.onAppear() {
            userService.getPurchaserInfo()
        }
    }
    
    // MARK: - progress view
    
    var progressView: some View {
        ZStack {
            Color.Palette.background.ignoresSafeArea().opacity(0.3)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.Palette.accentContent))
                .scaleEffect(1.5, anchor: .center)
                .animation(.easeOut, value: isLoading)
        }
    }
    
    // MARK: - profile button
    
    private var profileButton: some View {
        Menu {
            Button(action: {
                isLoading = true
                userService.isLoggedIn
                    ? userService.logout { isLoading = false }
                    : userService.login { isLoading = false }
            }) {
                Label(
                    userService.isLoggedIn ? "Log out" : "Log in",
                    systemImage: userService.isLoggedIn
                        ? Image.System.Name.logout
                        : Image.System.Name.login
                )
                .font(.headline)
                .foregroundColor(Color.Palette.accent)
            }
        }
        label: {
            HStack {
                Image(
                    systemName: userService.isLoggedIn
                        ? Image.System.Name.profile
                        : Image.System.Name.profileLoggedOut
                )
                Text(userService.user?.name ?? "Profile")
                    .font(.headline)
            }
            .foregroundColor(Color.Palette.accent)
            .frame(width: 100, height: 30, alignment: .leading)
        }
    }
    
    // MARK: - icon
    
    private var icon: some View {
        Image.Gallery.thinking
            .resizable()
            .frame(width: 300, height: 300, alignment: .center)
    }
    
    // MARK: - button
    
    private var button: some View {
        Button {
            guard !userService.isPremium else {
                updateNavigationWhen(isPremium: true)
                return
            }
            isLoading = true
            paywallService.getPaywalls { error in
                isLoading = false
                if let error = error {
                    alertMessage = error.localizedDescription
                    shouldShowAlert = true
                    return
                }
                updateNavigationWhen(isPremium: false)
            }
        } label: {
            Label("Premium Stuff", systemImage: buttonImageName)
                .font(.title)
                .tint(Color.Palette.accent)
        }.fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - premium
    
    private var premiumStuffView: some View {
        NavigationLink(
            destination: PremiumStuffView()
                .navigationBarTitle("Premium stuff")
                    .foregroundColor(Color.Palette.accent)
                .navigationBarBackButtonHidden(false)
                .navigationBarHidden(false),
            isActive: $showingPremiumStuff
        ) {
            EmptyView()
        }
    }
    
    private func updateNavigationWhen(isPremium: Bool) {
        showingPaywall = !isPremium
        showingPremiumStuff = isPremium
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showingPaywall: .constant(false))
    }
}
