//
//  CategoriesListView.swift
//  AdaptyRecipes-SwiftUI
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import SwiftUI

struct CategoriesListView: View {
    @EnvironmentObject private var viewModel: MainViewModel
    @State private var showPaywall: Bool = false

    var body: some View {
        List {
            Section(header: Text("Basic Recipes")) {
                ForEach(CategoryModel.allCases.filter { !$0.isPremium }) { category in
                    NavigationLink(destination: self.recipeDetails(for: category)) {
                        self.recipeRow(for: category)
                    }
                }
            }
            Section(header: Text("Premium Recipes")) {
                ForEach(CategoryModel.allCases.filter { $0.isPremium }) { category in
                    if self.viewModel.isPremiumUser {
                        NavigationLink(destination: self.recipeDetails(for: category)) {
                            self.recipeRow(for: category)
                        }
                    } else {
                        Button {
                            self.showPaywall = true
                        } label: {
                            self.recipeRow(for: category)
                        }
                    }
                }
            }
        }
        .navigationTitle("Adapty Recipes")
        .paywall(isPresented: $showPaywall, placementId: AppConstants.placementId)
    }

    @ViewBuilder
    private func recipeRow(for category: CategoryModel) -> some View {
        HStack {
            Text(category.emoji)
                .font(.largeTitle)
            Text(category.title)
                .font(.headline)
                .padding(.leading, 5)
        }
        .foregroundColor(.primary)
    }

    @ViewBuilder
    private func recipeDetails(for category: CategoryModel) -> some View {
        List {
            Text("Recipe 1 for \(category.title)")
            Text("Recipe 2 for \(category.title)")
        }
        .navigationTitle(category.title)
    }
}

#Preview {
    NavigationView {
        CategoriesListView()
            .environmentObject(MainViewModel())
    }
}
