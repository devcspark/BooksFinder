//
//  Extension+String.swift
//  BooksFinder
//
//  Created by iOS_DEV on 2022/03/31.
//

import Foundation
extension String {
    var localized:String {
        return NSLocalizedString(self, comment: "")
    }
}
