//
//  PaywallView.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Foundation
import SwiftUI

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var paywallService: PaywallService
    @EnvironmentObject var userService: UserService
    @State var isLoading: Bool = false
    @State var errorAlertMessage: String?
    @State var shouldShowErrorAlert: Bool = false
    @State var alertMessage: String?
    @State var shouldShowAlert: Bool = false
    
    // MARK: - body
    
    var body: some View {
        ZStack {
            Color.Palette.accent.ignoresSafeArea()
            VStack {
                topCloseButton
                Spacer()
                descriptionGroup
                Spacer()
                buttonGroup
            }
            .disabled(isLoading)
            progressView
                .isHidden(!isLoading)
        }.onAppear() {
            paywallService.logPaywallDisplay()
        }
    }
    
    // MARK: - top close button
    
    var topCloseButton: some View {
        HStack {
            Button(
                role: .destructive,
                action: {
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Image.System.close
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.Palette.accentContent)
                }
            ).padding()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - description
    
    var descriptionGroup: some View {
        VStack {
            Image(paywallService.paywallViewModel.iconName)
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
            Text(paywallService.paywallViewModel.description)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(Color.Palette.accentContent)
        .padding()
    }
        
    // MARK: - button group
    
    var buttonGroup: some View {
        VStack(alignment: .center, spacing: 12) {
            buyButton
            cancelButton
            restoreButton
        }
        .padding()
    }
    
    // MARK: - buyButton
    
    var buyButton: some View {
        Button(
            action: {
                guard let product = paywallService.paywall?.products.first else {
                    errorAlertMessage = "No product found"
                    shouldShowErrorAlert = true
                    return
                }
                isLoading = true
                userService.makePurchase(for: product) { succeeded, error in
                    isLoading = false
                    guard succeeded else {
                        error.map { print($0) }
                        errorAlertMessage = "Ooops! Error Occured"
                        shouldShowErrorAlert = true
                        return
                    }
                    alertMessage = "Success!"
                    shouldShowAlert = true
                }
            },
            label: {
                Text(paywallService.paywallViewModel.buyActionTitle)
                    .font(.title2)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.Palette.accent)
                    .background(Color.Palette.accentContent)
                    .cornerRadius(30)
            }
        )
    }
    
    // MARK: - cancel button
    
    var cancelButton: some View {
        Button(
            role: .cancel,
            action: { presentationMode.wrappedValue.dismiss() },
            label: {
                Text(paywallService.paywallViewModel.cancelActionTitle)
                    .font(.title2)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.Palette.accentContent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.Palette.accentContent, lineWidth: 2)
                )
            }
        )
    }
    
    // MARK: - restore button
    
    var restoreButton: some View {
        Button(
            role: .none,
            action: {
                isLoading = true
                userService.restorePurchases { isPremium, error in
                    isLoading = false
                    guard error == nil else {
                        errorAlertMessage = "Could not restore purchases."
                        shouldShowErrorAlert = true
                        return
                    }
                    alertMessage = "Successfully restored purchases!"
                    shouldShowAlert = true
                }
            },
            label: {
                Text(paywallService.paywallViewModel.restoreActionTitle)
                    .font(.title3)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.Palette.accentContent)
            }
        )
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
        .alert(errorAlertMessage ?? "Error occurred", isPresented: $shouldShowErrorAlert) {
            Button("OK", role: .cancel) {
                errorAlertMessage = nil
                shouldShowErrorAlert = false
            }
        }
        .alert(alertMessage ?? "Success!", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {
                alertMessage = nil
                shouldShowAlert = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
