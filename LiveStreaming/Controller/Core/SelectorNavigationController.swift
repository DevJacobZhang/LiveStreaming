//
//  SelectorNavigationController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/18.
//

import UIKit

class SelectorNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if APICaller.shared.mainAuth.currentUser != nil {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {return}
            setViewControllers([vc], animated: false)
        } else {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") else {return}
            setViewControllers([vc], animated: false)
        }
    }

}
