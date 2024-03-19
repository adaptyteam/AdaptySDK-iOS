//
//  EventsError.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

enum EventsError: Error {
    case sending(AdaptyError.Source, error: HTTPError)
    case encoding(AdaptyError.Source, error: Error)
    case decoding(AdaptyError.Source, error: Error)
    case interrupted(AdaptyError.Source)
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
        case let .interrupted(source):
            "EventsError.interrupted(\(source))"
        }
    }
}

extension EventsError {
    var source: AdaptyError.Source {
        switch self {
        case let .sending(src, _),
             let .encoding(src, _),
             let .decoding(src, _),
             let .interrupted(src): src
        }
    }

    var isInterrupted: Bool {
        switch self {
        case .interrupted: true
        case let .sending(_, error: error): error.isCancelled
        default: false
        }
    }

    var originalError: Error? {
        switch self {
        case let .sending(_, error): error
        case let .encoding(_, error),
             let .decoding(_, error): error
        default: nil
        }
    }
}

extension EventsError {
    static func sending(
        _ error: HTTPError,
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

    static func interrupted(
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) -> Self {
        .interrupted(AdaptyError.Source(
            file: file,
            function: function,
            line: line
        ))
    }
}
