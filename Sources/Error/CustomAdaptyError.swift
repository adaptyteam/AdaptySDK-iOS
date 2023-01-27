//
//  CustomAdaptyError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

public protocol CustomAdaptyError: CustomStringConvertible, CustomDebugStringConvertible, CustomNSError {
    var originalError: Error? { get }
    var adaptyErrorCode: AdaptyError.ErrorCode { get }
}
