//
//  EventsStorage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

protocol EventsStorage: AnyObject, Sendable {
    func setEventCounter(_: Int)
    func getEventCounter() -> Int
    func setEvents(_: [Data])
    func getEvents() -> [Data]?
}
