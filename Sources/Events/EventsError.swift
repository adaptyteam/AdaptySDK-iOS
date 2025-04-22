//
//  EventsError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

enum EventsError: Error {
    case sending(AdaptyError.Source, error: Error)
    case encoding(AdaptyError.Source, error: Error)
    case decoding(AdaptyError.Source, error: Error)
}

extension EventsError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .sending(source, error: error):
            "EventsError.sending(\(source), \(error))"
        case let .encoding(source, error: error):
            "EventsError.encoding(\(source), \(error))"
        case let .decoding(source, error: error):
            "EventsError.decoding(\(source), \(error))"
        }
    }
}

extension EventsError {
    var source: AdaptyError.Source {
        switch self {
        case let .sending(src, _),
             let .encoding(src, _),
             let .decoding(src, _): src
        }
    }

    var isInterrupted: Bool {
        switch self {
        case let .sending(_, error): (error as? HTTPError)?.isCancelled ?? false
        default: false
        }
    }

    var originalError: Error? {
        switch self {
        case let .sending(_, error): error
        case let .encoding(_, error),
             let .decoding(_, error): error
        }
    }
}

extension EventsError {
    static func sending(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .sending(
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func encoding(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .encoding(
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }

    static func decoding(
        _ error: Error,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .decoding(
            AdaptyError.Source(
                file: file,
                function: function,
                line: line
            ),
            error: error
        )
    }
}
