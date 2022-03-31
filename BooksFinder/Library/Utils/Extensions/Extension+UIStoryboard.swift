//
//  Extension+UIStoryboard.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/25.
//

import UIKit

extension UIStoryboard {
    public struct Name {
        public let name: String
        
        public init(_ name: String) {
            self.name = name
        }
        
        public func viewController(identifier: String) -> UIViewController {
            let storyboard = UIStoryboard(name: self.name, bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: identifier)
        }

        public func initialViewController() -> UIViewController? {
            let storyboard = UIStoryboard(name: self.name, bundle: nil)
            return storyboard.instantiateInitialViewController()
        }
    }
}

extension UIStoryboard.Name {
    public static var Main = UIStoryboard.Name("Main")
    public static var BookFinder = UIStoryboard.Name("BookFinder")
}
