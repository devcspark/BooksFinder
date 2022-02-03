//
//  PopupViewController.swift
//  BooksFinder
//
//  Created by ParkChunsoo on 2021/07/25.
//

import UIKit

class PopupViewController: NSObject {
    static func showConfirm(source:UIViewController?, title: String? = nil, message: String, completion:(()->Void)? = nil) {
        var actions:[UIAlertAction]?
        if let comp = completion {
            actions = []
            actions?.append(UIAlertAction(title: NSLocalizedString("common_ok", comment: "확인"),
                                          style: .cancel, handler: { _ in
                                            comp()
                                          }))
        }
        
        PopupViewController.show(source: source, title: title, message: message, actions: actions)
    }
    
    static func show(source:UIViewController?, title: String? = nil, message: String, actions:[UIAlertAction]?) {
        var localActions = actions
        if(localActions == nil){
            localActions = [UIAlertAction(title: NSLocalizedString("common_ok", comment: "확인"), style: .default,
                                          handler: nil)]
        }
        
        UIAlertController(aTitle: title,
                          message: message,
                          preferredStyle: .alert,
                          actions: localActions).show(source: source)
    }
    
    static func show(source:UIViewController?, message:String, cancelTitle:String, defaultTitle:String, completion: @escaping((Bool)->Void) ) {
        PopupViewController.show(
            source: source,
            title: nil,
            message: message,
            actions: [UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
                completion(false)
            }),
            UIAlertAction(title: defaultTitle, style: .default, handler: { _ in
                completion(true)
            })])
    }
}
