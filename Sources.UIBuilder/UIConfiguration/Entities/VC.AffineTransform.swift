//
//  VC.AffineTransform.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.03.2026.
//

import Foundation

extension VC {
    /// [ a  b  0 ]
    /// [ c  d  0]
    /// [ x  y  1]
    /// a, d - scale x, scale y
    /// b, c - rotation/ skew
    /// x, y - offset
    enum AffineTransform: Sendable, Hashable {
        case full(a: Double, b: Double, c: Double, d: Double, offset: VC.Offset)
        case offset(VC.Offset)
        case empty
    }
}

extension VC.AffineTransform {
    @inlinable
    init(
        a: Double = 1,
        b: Double = 0,
        c: Double = 0,
        d: Double = 1,
        x: VC.Unit = .point(0),
        y: VC.Unit = .point(0)
    ) {
        let offset = VC.Offset(x: x, y: y)
        guard a == 1, b == 0, c == 0, d == 1 else {
            self = .full(a: a, b: b, c: c, d: d, offset: offset)
            return
        }

        guard offset.isZero else {
            self = .offset(offset)
            return
        }

        self = .empty
    }

    @inlinable
    var isEmpty: Bool {
        switch self {
        case let .full(a, b, c, d, offset):
            a == 1 && b == 0 && c == 0 && d == 1 && offset.isZero
        case let .offset(offset):
            offset.isZero
        case .empty:
            true
        }
    }

    @inlinable
    var hasOffsetOnly: Bool {
        switch self {
        case let .full(a, b, c, d, _):
            a == 1 && b == 0 && c == 0 && d == 1
        case .offset:
            true
        case .empty:
            true
        }
    }

    @inlinable
    var full: (a: Double, b: Double, c: Double, d: Double, x: VC.Unit, y: VC.Unit) {
        switch self {
        case let .full(a, b, c, d, offset):
            (a, b, c, d, offset.x, offset.y)
        case let .offset(offset):
            (1, 0, 0, 1, offset.x, offset.y)
        case .empty:
            (1, 0, 0, 1, .zero, .zero)
        }
    }

    @inlinable
    var offsetComponent: VC.Offset {
        switch self {
        case let .full(_, _, _, _, offset),
             let .offset(offset):
            offset
        case .empty:
            .init(x: .zero, y: .zero)
        }
    }
}

