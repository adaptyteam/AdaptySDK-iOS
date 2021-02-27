//
//  Platform.swift
//  Adapty
//
//  Created by Dmitry Obukhov on 3/17/20.
//
#if os(iOS)
import UIKit

typealias Application = UIApplication
typealias ApplicationDelegate = UIApplicationDelegate
#elseif os(macOS)
import AppKit

typealias Application = NSApplication
typealias ApplicationDelegate = NSApplicationDelegate
#endif
