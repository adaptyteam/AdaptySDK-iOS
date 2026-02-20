//
//  MainView.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import SwiftUI

struct MainView: View {
    @State private var selection: SidebarSection? = .recipes

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("Adapty Recipes")
        } detail: {
            switch selection ?? .recipes {
            case .recipes:
                NavigationStack {
                    CategoriesListView()
                }
            case .profile:
                NavigationStack {
                    ProfileView()
                }
            }
        }
    }
}

private enum SidebarSection: String, CaseIterable, Identifiable {
    case recipes
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recipes:
            return "Recipes"
        case .profile:
            return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .recipes:
            return "list.bullet"
        case .profile:
            return "person"
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
