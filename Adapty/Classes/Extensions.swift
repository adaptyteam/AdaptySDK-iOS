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

extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}

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

@available(iOS 11.2, *)
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

@available(iOS 11.2, *)
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

extension UIApplication {
    
    static var topOffset: CGFloat {
        if #available(iOS 11.0, *), let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            return safeAreaInsetsTop
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
}
