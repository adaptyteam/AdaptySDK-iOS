//
//  OnboardingsUnknownMessageError.swift
//
//
//  Created by Aleksei Valiano on 09.08.2024
//
//

import Foundation

struct OnboardingsUnknownMessageError: Error {
    let chanel: String
    let type: String?
}
