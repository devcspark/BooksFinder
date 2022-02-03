//
//  Extension+UIViewController.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/25.
//

import UIKit

extension UIViewController {
    
    @objc public var isPresented: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }

    public static func instantiate(storyboard: UIStoryboard.Name, identifier: String) -> UIViewController {
        return UIStoryboard(name: storyboard.name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }

    public static func instantiate(storyboard: UIStoryboard.Name) -> Self? {
        return instantiate(storyboard: storyboard, identifier: String(describing: self)) as? Self
    }
}
