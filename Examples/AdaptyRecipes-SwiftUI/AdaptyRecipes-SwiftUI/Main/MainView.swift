//
//  MainView.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            NavigationView {
                CategoriesListView()
            }
            .tabItem { Label("Recipes", systemImage: "list.bullet") }
            
            NavigationView {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
        
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
