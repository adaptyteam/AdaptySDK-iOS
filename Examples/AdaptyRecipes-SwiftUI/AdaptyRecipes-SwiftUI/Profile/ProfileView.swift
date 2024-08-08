//
//  ProfileView.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

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

struct ProfileView: View {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    @EnvironmentObject private var viewModel: MainViewModel

    var body: some View {
        List {
            userIdSection()
            adaptyProfileIdSection()
            profileSection()
        }
        .navigationTitle("Profile")
    }

    @ViewBuilder func adaptyProfileIdSection() -> some View {
        Section {
            if let profileId = viewModel.profile?.profileId, !profileId.isEmpty {
                Button(profileId) {
                    UIPasteboard.general.string = profileId
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

    @State private var showLogInDialog = false
    @State private var enteredUserId: String = ""

    @ViewBuilder func userIdSection() -> some View {
        Section {
            if let userId = viewModel.userId {
                ListItemView(title: "User Id", subtitle: userId)

                Button("Logout") {
                    viewModel.logout()
                }
            } else {
                Button("Log In") {
                    showLogInDialog = true
                }
                .alert("Log In", isPresented: $showLogInDialog) {
                    TextField("Enter user id", text: $enteredUserId)
                    Button("OK", action: {
                        guard !enteredUserId.isEmpty else { return }
                        viewModel.login(to: enteredUserId)
                        enteredUserId = ""
                    })
                }
            }
        } header: {
            Text("Customer User Id")
        }
    }

    @ViewBuilder func profileSection() -> some View {
        Section {
            if let profile = viewModel.profile {
                if let level = profile.accessLevels[AppConstants.accessLevelId] {
                    ListStatusItemView(title: "Premium",
                                       state: viewModel.getProfileInProgress ? .loading : (level.isActive ? .success : .failure),
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
                                       state: viewModel.getProfileInProgress ? .loading : .failure,
                                       expanded: nil)
                }

                Text("Subscriptions: \(profile.subscriptions.count)")
                Text("NonSubscriptions: \(profile.nonSubscriptions.count)")
            } else {
                ListStatusItemView(title: "Premium", state: .loading, expanded: nil)
            }

            Button {
                Task {
                    await viewModel.reloadProfile()
                }
            } label: {
                Text("Update")
            }
            
            Button {
                Task {
                    await viewModel.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
            }
        } header: {
            Text("Profile")
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(MainViewModel())
    }
}
