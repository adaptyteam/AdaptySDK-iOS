//
//  Dev_MockProduct.swift
//  AdaptyDeveloperTools
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Foundation

struct Dev_MockProduct: ProductResolver, Sendable {
    var flowId: String { adaptyProductId }

    let adaptyProductId: String
    let paymentMode: PaymentModeValue

    private let name: String
    private let price: String
    private let currency: String

    init(id: String) {
        self.adaptyProductId = id

        let knownModes = ["free_trial", "pay_as_you_go", "pay_up_front"]

        var parsedName = id
        var parsedMode: String? = nil
        var parsedPrice = "0"
        var parsedCurrency = "usd"

        for mode in knownModes {
            if let range = id.range(of: "-\(mode)-") {
                parsedName = String(id[id.startIndex..<range.lowerBound])
                let afterMode = id[range.upperBound...]
                let parts = afterMode.split(separator: "-", maxSplits: 1)
                if let pricePart = parts.first {
                    parsedPrice = String(pricePart)
                }
                if parts.count > 1 {
                    parsedCurrency = String(parts[1])
                }
                parsedMode = mode
                break
            }
        }

        if parsedMode == nil, let range = id.range(of: "-default-") {
            parsedName = String(id[id.startIndex..<range.lowerBound])
            let afterMode = id[range.upperBound...]
            let parts = afterMode.split(separator: "-", maxSplits: 1)
            if let pricePart = parts.first {
                parsedPrice = String(pricePart)
            }
            if parts.count > 1 {
                parsedCurrency = String(parts[1])
            }
        }

        self.name = parsedName
        self.paymentMode = parsedMode
        self.price = parsedPrice
        self.currency = parsedCurrency
    }

    private var currencySymbol: String {
        switch currency.lowercased() {
        case "usd": return "$"
        case "eur": return "€"
        case "gbp": return "£"
        default: return currency.uppercased() + " "
        }
    }

    private var formattedPrice: String {
        "\(currencySymbol)\(price)"
    }

    func value(byTag tag: TextProductTag) -> TextTagValue? {
        switch tag {
        case .title:
            return .value(name.capitalized)
        case .price:
            return .value(formattedPrice)
        case .pricePerDay:
            return .value("\(formattedPrice)/day")
        case .pricePerWeek:
            return .value("\(formattedPrice)/week")
        case .pricePerMonth:
            return .value("\(formattedPrice)/month")
        case .pricePerYear:
            return .value("\(formattedPrice)/year")
        case .offerPrice:
            switch paymentMode {
            case "free_trial":
                return .value("\(currencySymbol)0.00")
            case "pay_as_you_go", "pay_up_front":
                return .value(formattedPrice)
            default:
                return .notApplicable
            }
        case .offerPeriods:
            switch paymentMode {
            case "free_trial":
                return .value("1 week")
            case "pay_as_you_go":
                return .value("3 months")
            case "pay_up_front":
                return .value("1 year")
            default:
                return .notApplicable
            }
        case .offerNumberOfPeriods:
            switch paymentMode {
            case "free_trial":
                return .value("1")
            case "pay_as_you_go":
                return .value("3")
            case "pay_up_front":
                return .value("1")
            default:
                return .notApplicable
            }
        }
    }
}

#endif
