//
//  Extensions.swift
//  python-integration
//
//  Created by Ilja Kosynkin on 01/09/2018.
//  Copyright © 2018 Syllogismobile. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    static var startOfCurrentDay: Date? {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
    }
    
    static var endOfCurrentDay: Date? {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
    }
}

protocol Defaultable {
    static var `default`: Self { get }
}

extension String: Defaultable {
    static var empty: String {
        return ""
    }
    
    static var `default`: String {
        return .empty
    }
}

extension Optional where Wrapped: Defaultable {
    var orDefault: Wrapped {
        if let unwrapped: Wrapped = self {
            return unwrapped
        }
    
        return Wrapped.default
    }
}

extension Int {
    var float: CGFloat {
        return CGFloat(self)
    }
}

extension UIColor {
    static var shadow: UIColor {
        return .from(red: 42, green: 49, blue: 50, alpha: 1.0)
    }
    
    static var mist: UIColor {
        return .from(red: 144, green: 175, blue: 197, alpha: 1.0)
    }
    
    static func from(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: red.float / 255.0, green: green.float / 255.0, blue: blue.float / 255.0, alpha: alpha)
    }
}

extension CGColor {
    static var shadow: CGColor {
        return UIColor.shadow.cgColor
    }
    
    static var mist: CGColor {
        return UIColor.mist.cgColor
    }
}
