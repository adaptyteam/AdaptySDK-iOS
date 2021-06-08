//
//  Extensions.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 28/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation
import StoreKit

extension Date {
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter.string(from: self)
    }
    
    var iso8601Value: String {
        return DateFormatter.iso8601Formatter.string(from: self)
    }
    
}

#if canImport(UIKit)
extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("", { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        })
    }()

}
#endif

extension Dictionary {
    
    func attributes() throws -> Parameters  {
        guard let json = self as? Parameters else {
            throw AdaptyError.invalidProperty("JSON response", self)
        }
        
        guard var attributes = json["attributes"] as? Parameters else {
            throw AdaptyError.missingParam("JSON response - attributes")
        }
        
        if let id = json["id"] as? String {
            attributes["id"] = id
        }
        
        return attributes
    }
    
    static func formatData(with id: Any, type: String, attributes: Parameters) -> Parameters {
        var data = ["id": id, "type": type]
        if attributes.count > 0 {
            data["attributes"] = attributes
        }
        return ["data": data]
    }
    
}

extension UUID {
    
    var stringValue: String {
        return self.uuidString.lowercased()
    }
    
}

extension String {
    
    var dateValue: Date? {
        return DateFormatter.iso8601Formatter.date(from: self)
    }
    
}

extension DateFormatter {
    
    static var iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
}

extension NSDecimalNumber {
    
    func localizedPrice(for locale: Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self)
    }
    
}

@available(iOS 11.2, macOS 10.13.2, *)
extension SKProductSubscriptionPeriod {
    
    func localizedPeriod(for locale: Locale) -> String? {
        switch unit {
        case .day:
            if numberOfUnits == 7 { return locale.localizedComponents(weekOfMonth: 1) }
            return locale.localizedComponents(day: numberOfUnits)
        case .week:
            return locale.localizedComponents(weekOfMonth: numberOfUnits)
        case .month:
            return locale.localizedComponents(month: numberOfUnits)
        case .year:
            return locale.localizedComponents(year: numberOfUnits)
        @unknown default:
            return nil
        }
    }
    
}

@available(iOS 11.2, macOS 10.13.2, *)
extension SKProductDiscount {
    
    func localizedNumberOfPeriods(for locale: Locale) -> String? {
        // ignore one period strings
        if numberOfPeriods <= 1 { return nil }
        
        switch subscriptionPeriod.unit {
        case .day:
            return locale.localizedComponents(day: numberOfPeriods)
        case .week:
            return locale.localizedComponents(weekOfMonth: numberOfPeriods)
        case .month:
            return locale.localizedComponents(month: numberOfPeriods)
        case .year:
            return locale.localizedComponents(year: numberOfPeriods)
        @unknown default:
            return nil
        }
    }
    
}

extension Locale {
    
    func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = self
        
        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year
        
        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
    
}

#if os(iOS)
extension UIApplication {
    
    static var topOffset: CGFloat {
        if #available(iOS 11.0, *), let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            return safeAreaInsetsTop
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    static var bottomOffset: CGFloat {
        if #available(iOS 11.0, *), let safeAreaInsetsBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
            return safeAreaInsetsBottom
        } else {
            return 0
        }
    }
    
}
#endif

private let noInternetNetworkErrors = [NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost,
                                       NSURLErrorDNSLookupFailed, NSURLErrorResourceUnavailable,
                                       NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost]

extension NSError {
    var isNetworkConnectionError: Bool {
        return noInternetNetworkErrors.contains(code)
    }
}
