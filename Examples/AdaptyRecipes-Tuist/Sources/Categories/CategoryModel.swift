//
//  CategoryModel.swift
//  AdaptyRecipes-Tuist
//
//  Created by Aleksey Goncharov on 28.06.2024.
//

import Foundation

enum CategoryModel: String, CaseIterable, Identifiable {
    case simpleSalads = "Simple Salads"
    case pastaDishes = "Pasta Dishes"
    case soups = "Soups"
    case breakfasts = "Breakfasts"
    case snacks = "Snacks"
    case wrapsAndSandwiches = "Wraps and Sandwiches"
    case gourmetDishes = "Gourmet Dishes"
    case desserts = "Desserts"
    case internationalCuisine = "International Cuisine"
    case seafoodSpecials = "Seafood Specials"
    case pairings = "Pairings"
    case superfoodRecipes = "Superfood Recipes"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .simpleSalads: return "🥗"
        case .pastaDishes: return "🍝"
        case .soups: return "🍲"
        case .breakfasts: return "🍳"
        case .snacks: return "🍌"
        case .wrapsAndSandwiches: return "🥙"
        case .gourmetDishes: return "🍣"
        case .desserts: return "🍰"
        case .internationalCuisine: return "🍛"
        case .seafoodSpecials: return "🍤"
        case .pairings: return "🍷"
        case .superfoodRecipes: return "🥑"
        }
    }

    var title: String { rawValue }

    var isPremium: Bool {
        switch self {
        case .simpleSalads, .pastaDishes, .soups, .breakfasts, .snacks, .wrapsAndSandwiches:
            return false
        case .gourmetDishes, .desserts, .internationalCuisine, .seafoodSpecials, .pairings, .superfoodRecipes:
            return true
        }
    }
}

extension CategoryModel {
    enum PresentationStyle: String {
        case modal
        case navigation
    }

    var presentationStyle: PresentationStyle {
        switch self {
        case .gourmetDishes, .internationalCuisine, .pairings:
            return .modal
        default:
            return .navigation
        }
    }
}
