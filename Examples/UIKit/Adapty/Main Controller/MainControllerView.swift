//
//  MainControllerView.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 29.09.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import SwiftUI

struct ListItemView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let subtitle = subtitle {
                Text(subtitle)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ListSelectedItemView: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ListStatusItemView: View {
    enum State {
        case loading
        case success
        case failure
    }

    let title: String
    let state: State
    let expanded: Bool?
    var action: (() -> Void)?

    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 8.0)
                switch state {
                case .loading:
                    ProgressView()
                case .success:
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                case .failure:
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }

                Spacer()

                if let expanded = expanded {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                }
            }
        }
    }
}

struct MainControllerView: View {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    let onShowExamplePaywall: (AdaptyPaywall, [AdaptyPaywallProduct]) -> Void

    @EnvironmentObject var presenter: MainPresenter

    @State var customerUserId: String = ""

    @ViewBuilder func adaptyProfileIdSection() -> some View {
        Section {
            if let adaptyId = presenter.adaptyId, !adaptyId.isEmpty {
                Button(adaptyId) {
                    UIPasteboard.general.string = adaptyId
                }
                .foregroundColor(.black)
            } else {
                Text("Not Set")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Adapty Profile Id")
        } footer: {
            Text("👆Tap to Copy")
        }
    }

    @ViewBuilder func customerUserIdSection() -> some View {
        Section {
            TextField("Enter Customer User Id", text: $presenter.customerUserIdEdited)
            Button("Identify") {
                presenter.identifyUser(presenter.customerUserIdEdited)
            }
            .disabled(presenter.customerUserIdEdited == presenter.customerUserId || presenter.customerUserIdEdited.isEmpty)
        } header: {
            Text("Customer User Id")
        }
    }

    @ViewBuilder func profileSection() -> some View {
        Section {
            if let profile = presenter.profile {
                if let level = profile.accessLevels["premium"] {
                    ListStatusItemView(title: "Premium",
                                       state: presenter.getProfileInProgress ? .loading : (level.isActive ? .success : .failure),
                                       expanded: !presenter.profileCollapsed) {
                        withAnimation {
                            presenter.profileCollapsed.toggle()
                        }
                    }

                    if !presenter.profileCollapsed {
                        ListItemView(title: "Is Lifetime", subtitle: level.isLifetime ? "true" : "false")

                        if let activatedAt = level.activatedAt {
                            ListItemView(title: "Activated At", subtitle: Self.dateFormatter.string(from: activatedAt))
                        }

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
                    }
                } else {
                    ListStatusItemView(title: "Access Levels: \(profile.accessLevels.count)",
                                       state: presenter.getProfileInProgress ? .loading : .failure,
                                       expanded: nil)
                }

                Text("Subscriptions: \(profile.subscriptions.count)")
                Text("NonSubscriptions: \(profile.nonSubscriptions.count)")
            } else {
                ListStatusItemView(title: "Premium", state: .loading, expanded: nil)
            }

            Button {
                presenter.getProfile()
            } label: {
                Text("Update")
            }
        } header: {
            Text("Profile")
        }
    }

    @ViewBuilder func paywallDetailsSection(paywall: AdaptyPaywall, products: [AdaptyPaywallProduct]?) -> some View {
        ListItemView(title: "Variation", subtitle: paywall.variationId)
        ListItemView(title: "Revision", subtitle: "\(paywall.revision)")

        if let products = products {
            ForEach(products, id: \.vendorProductId) { p in
                Button {
                    presenter.purchaseProduct(product: p)
                } label: {
                    HStack {
                        Text(p.vendorProductId)
                        Spacer()
                        Text(p.localizedPrice ?? "0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder func paywallSection() -> some View {
        Section {
            if let paywall = presenter.customPaywall, paywall.id == presenter.customPaywallId {
                ListStatusItemView(title: paywall.id, state: .success, expanded: !presenter.customPaywallCollapsed) {
                    withAnimation {
                        presenter.customPaywallCollapsed.toggle()
                    }
                }

                if !presenter.customPaywallCollapsed {
                    paywallDetailsSection(paywall: paywall, products: presenter.customPaywallProducts)
                }
            } else {
                ListStatusItemView(title: "No Paywall Loaded", state: .failure, expanded: nil)
            }

            TextField("Enter Paywall Id", text: $presenter.customPaywallId)
                .onSubmit {
                    presenter.reloadCustomPaywall()
                }

            Button {
                presenter.reloadCustomPaywall()
            } label: {
                Text("Load")
            }
            .disabled(presenter.customPaywallId.isEmpty)

        } header: {
            Text("Custom Paywall")
        } footer: {
            Text("Here you can load any paywall by its id and inspect the contents")
        }
    }

    @ViewBuilder func exampleABTestSection() -> some View {
        Section {
            if let paywall = presenter.exampleABTestPaywall {
                ListStatusItemView(title: paywall.id, state: .success, expanded: nil)

                paywallDetailsSection(paywall: paywall, products: presenter.exampleABTestProducts)

                Button {
                    PurchasesObserver.shared.loadInitialPaywallData()
                } label: {
                    Text("Refresh")
                }

                Button {
                    onShowExamplePaywall(paywall, presenter.exampleABTestProducts ?? [])
                } label: {
                    Text("Present Paywall")
                }
            } else {
                ListStatusItemView(title: "Paywall is loading", state: .loading, expanded: nil)
            }
        } header: {
            Text("Example A/B Test")
        } footer: {
            Text("Here is the example_ab_test paywall and its state")
        }
    }

    @ViewBuilder func actionsSection() -> some View {
        Section {
            Button {
                presenter.restorePurchases()
            } label: {
                Text("Restore Purchases")
            }

            Button {
                try? presenter.updateProfileAttributes()
            } label: {
                Text("Update Profile")
            }

            Button {
                presenter.updateAttribution()
            } label: {
                Text("Update Attribution")
            }

            ForEach(1 ... 3, id: \.self) { id in
                Button {
                    presenter.sendOnboardingEvent(name: "screen_\(id)", order: UInt(id))
                } label: {
                    Text("Send Onboarding Order \(id)")
                }
            }
        } header: {
            Text("Other Actions")
        }
    }

    @ViewBuilder func logoutSection() -> some View {
        Section {
            Button {
                presenter.logout()
            } label: {
                Text("Logout")
                    .foregroundColor(.red)
            }
        }
    }

    var body: some View {
        if presenter.isLoggingOut {
            ProgressView()
        } else {
            List {
                adaptyProfileIdSection()
                customerUserIdSection()
                profileSection()
                exampleABTestSection()
                paywallSection()
                actionsSection()
                logoutSection()

                ListItemView(title: "SDK Version", subtitle: Adapty.SDKVersion)
            }
        }
    }
}

struct MainControllerView_Previews: PreviewProvider {
    static var previews: some View {
        MainControllerView(onShowExamplePaywall: { _, _ in })
            .environmentObject(MainPresenter())
    }
}
