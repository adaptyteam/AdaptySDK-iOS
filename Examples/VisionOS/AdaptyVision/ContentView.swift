//
//  ContentView.swift
//  AdaptyVision
//
//  Created by Aleksey Goncharov on 23.1.24..
//

import Adapty
import SwiftUI
class ContentViewModel: ObservableObject {
    init() {
        Adapty.logLevel = .verbose
        Adapty.activate("public_live_iNuUlSsN.83zcTTR8D5Y8FI9cGUI6")
    }

    @Published var profile: AdaptyProfile?
    @Published var paywall: AdaptyPaywall?
    @Published var products: [AdaptyPaywallProduct]?

    @MainActor
    func getProfile() async {
        do {
            profile = try await Adapty.getProfile()
        } catch {
        }
    }

    @MainActor
    func start() async {
        do {
            let paywall = try await Adapty.getPaywall(placementId: "example_ab_test")
            let products = try await Adapty.getPaywallProducts(paywall: paywall)

            self.paywall = paywall
            self.products = products
        } catch {
        }
    }

    @MainActor
    func makePurchase(_ product: AdaptyPaywallProduct) async {
        do {
            profile = try await Adapty.makePurchase(product: product).profile
        } catch {
        }
    }
}

struct ContentView: View {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    @EnvironmentObject var viewModel: ContentViewModel

    @ViewBuilder func profileSection() -> some View {
        Section {
            if let profile = viewModel.profile {
                if let level = profile.accessLevels["premium"] {
                    ListStatusItemView(title: "Premium",
                                       state: level.isActive ? .success : .failure,
                                       expanded: nil)

                    ListItemView(title: "Is Lifetime", subtitle: level.isLifetime ? "true" : "false")
                    ListItemView(title: "Activated At", subtitle: Self.dateFormatter.string(from: level.activatedAt))

                    if let renewedAt = level.renewedAt {
                        ListItemView(title: "Renewed At", subtitle: Self.dateFormatter.string(from: renewedAt))
                    }

                    if let expiresAt = level.expiresAt {
                        ListItemView(title: "Expires At", subtitle: Self.dateFormatter.string(from: expiresAt))
                    }

                    ListItemView(title: "Will Renew", subtitle: level.willRenew ? "true" : "false")

                    if let unsubscribedAt = level.unsubscribedAt {
                        ListItemView(title: "Unsubscribed At", subtitle: Self.dateFormatter.string(from: unsubscribedAt))
                    }

                    if let billingIssueDetectedAt = level.billingIssueDetectedAt {
                        ListItemView(title: "Billing Issue At", subtitle: Self.dateFormatter.string(from: billingIssueDetectedAt))
                    }

                    if let reason = level.cancellationReason {
                        ListItemView(title: "Cancellation Reason", subtitle: reason)
                    }

                } else {
                    ListStatusItemView(title: "Access Levels: \(profile.accessLevels.count)",
                                       state: .failure,
                                       expanded: nil)
                }

                Text("Subscriptions: \(profile.subscriptions.count)")
                Text("NonSubscriptions: \(profile.nonSubscriptions.count)")
            } else {
                ListStatusItemView(title: "Premium", state: .loading, expanded: nil)
            }

            Button {
                Task {
                    await viewModel.getProfile()
                }
            } label: {
                Text("Update")
            }
        } header: {
            Text("Profile")
        }
    }

    var body: some View {
        NavigationStack {
            List {
                profileSection()

                Section {
                    if let paywall = viewModel.paywall {
                        Text(paywall.placementId)

                    } else {
                        ProgressView()
                    }
                } header: {
                    Text("Paywall")
                }

                Section {
                    if let products = viewModel.products {
                        ForEach(products, id: \.vendorProductId) { product in
                            Button(product.vendorProductId) {
                                Task {
                                    await viewModel.makePurchase(product)
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                } header: {
                    Text("Products")
                }
            }
            .padding()
            .navigationTitle("Welcome to Adapty Vision!")
            .task {
                await viewModel.getProfile()
            }
            .task {
                await viewModel.start()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ContentViewModel())
}
