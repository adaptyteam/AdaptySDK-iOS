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
            backgorundColor.ignoresSafeArea()
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
                        .foregroundColor(textColor)
                }
            ).padding()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - description
    
    var descriptionGroup: some View {
        VStack {
            Image(paywallService.paywallViewModel?.iconName ?? "")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200, alignment: .center)
            Text(paywallService.paywallViewModel?.description ?? "")
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(textColor)
        .padding()
    }
        
    // MARK: - button group
    
    var buttonGroup: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                let model = paywallService.paywallViewModel
                ForEach(model?.productModels ?? [], id: \.id) { product in
                    buyButton(title: model?.buyActionTitle ?? "", product: product)
                }
            }
            restoreButton
        }
        .padding()
    }
    
    // MARK: - buyButton
    
    func buyButton(title: String, product: ProductItemModel) -> some View {
        Button(
            action: {
                guard
                    let product = paywallService.paywall?.products.first(where: { $0.vendorProductId == product.id })
                else {
                    updateErrorAlert(isShown: true, title: "No product found")
                    return
                }
                isLoading = true
                userService.makePurchase(for: product) { succeeded, error in
                    isLoading = false
                    guard succeeded else {
                        error.map { print($0) }
                        return
                    }
                    alertMessage = "Success!"
                    shouldShowAlert = true
                }
            },
            label: { buyButtonLabel(title: title, product: product) }
        )
    }
    
    func buyButtonLabel(title: String, product: ProductItemModel) -> some View {
        let discount = product.introductoryDiscount
        let discountText = discount.map { "\($0.localizedPeriod) for \($0.localizedPrice)"} ?? ""
        return ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(buyButtonColor)
            VStack {
                Text(product.period)
                    .font(.title)
                Text(title)
                    .font(.body)
                Text(product.priceString)
                    .font(.title2)
                Text(discountText)
                    .font(.title3)
                    .lineLimit(2)
                    .padding(.top, 10)
                    .isHidden(discount == nil, removeIfHidden: true)
            }
            .padding()
            .foregroundColor(buyButtonTextColor)
        }.frame(maxHeight: 200, alignment: .center)
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
                Text(paywallService.paywallViewModel?.restoreActionTitle ?? "")
                    .font(.title3)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(textColor)
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
    
    private func updateErrorAlert(isShown: Bool, title: String) {
        errorAlertMessage = title
        shouldShowErrorAlert = isShown
    }
}

// MARK: - Colors

extension PaywallView {
    var backgorundColor: Color {
        paywallService.paywallViewModel?.backgroundColor ?? Color.Palette.accent
    }
    
    var textColor: Color {
        paywallService.paywallViewModel?.textColor ?? Color.Palette.accentContent
    }
    
    var buyButtonTextColor: Color {
        paywallService.paywallViewModel?.buyButtonStyle.buttonTextColor ?? Color.Palette.accent
    }
    
    var buyButtonColor: Color {
        paywallService.paywallViewModel?.buyButtonStyle.buttonColor ?? Color.Palette.accentContent
    }
}

// MARK: - preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}
