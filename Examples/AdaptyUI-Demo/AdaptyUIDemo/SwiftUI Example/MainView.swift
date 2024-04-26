//
//  MainView.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.11.23..
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel

    @State var paywallId: String = ""

    var list: some View {
        List {
            Section {
                TextField("Paywall Id", text: $paywallId)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.none)

                Button("Load") {
                    Task {
                        await viewModel.loadPaywall(id: paywallId)
                    }
                }
            }

            if let paywall = viewModel.paywall {
                Section {
                    HStack {
                        Text("Variation Id")
                        Spacer()
                        Text(paywall.variationId)
                    }

                    Button("Load View") {
                        Task {
                            await viewModel.loadViewConfiguration()
                        }
                    }
                }
            }

            if let viewConfig = viewModel.viewConfig {
                Section {
                    HStack {
                        Text("Template")
                        Spacer()
                        Text(viewConfig.templateId)
                    }

                    Button("Present") {
                        paywallPresented = true
                    }
                }
            }
        }
    }

    @State var paywallPresented = false

    var body: some View {
        NavigationView {
            if let paywall = viewModel.paywall, let viewConfig = viewModel.viewConfig {
                list
                    .paywall(
                        isPresented: $paywallPresented,
                        paywall: paywall,
                        configuration: viewConfig,
                        didPerformAction: { action in
                            print("#Example# didPerformAction \(action)")
                            
                            switch action {
                            case .close:
                                paywallPresented = false
                            case let .openURL(url):
                                UIApplication.shared.open(url, options: [:])
                            default:
                                break
                            }
                        },
                        didSelectProduct: { print("#Example# didSelectProduct \($0.vendorProductId)") },
                        didStartPurchase: { print("#Example# didStartPurchase \($0.vendorProductId)") },
                        didFinishPurchase: { p, _ in print("#Example# didFinishPurchase \(p.vendorProductId)") },
                        didFailPurchase: { p, _ in print("#Example# didFailPurchase \(p.vendorProductId)") },
                        didCancelPurchase: { print("#Example# didCancelPurchase \($0.vendorProductId)") },
                        didStartRestore: { print("#Example# didStartRestore") },
                        didFinishRestore: { _ in print("#Example# didFinishRestore") },
                        didFailRestore: { print("#Example# didFailRestore \($0)") },
                        didFailRendering: { error in
                            paywallPresented = false
                            print("#Example# didFailRendering \(error)")
                        },
                        didFailLoadingProducts: { error in
                            print("#Example# didFailLoadingProducts \(error)")
                            return false
                        }
                    )
            } else {
                list
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
