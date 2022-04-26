//
//  LoginViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/6.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var headPhotoImageView: UIImageView!
    
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = NSLocalizedString("會員資訊", comment:"")
        
        headPhotoImageView.layer.cornerRadius = headPhotoImageView.frame.height / 2
        headPhotoImageView.layer.masksToBounds = true
        
        logoutButton.layer.cornerRadius = 20
        logoutButton.layer.masksToBounds = true
        
        nicknameLabel.text = NSLocalizedString("暱稱", comment: "") + ":"
        accountLabel.text = NSLocalizedString("帳號", comment: "") + ":"
        
        self.showInfoFromFirebase()
    }
    
    func showInfoFromFirebase() {
        guard let user = APICaller.shared.mainAuth.currentUser else { return }

        var userAccount = ""
        guard let strOfEmail = user.email else {return}

        for index in strOfEmail.indices {

            let word = String(strOfEmail[index])

            if word != "@" {
                userAccount += word
            } else {
                break
            }
        }
        self.accountLabel.text = NSLocalizedString("帳號", comment: "") + ":" + userAccount
        APICaller.shared.getCurrentUserInfo { result, error in
            if result != nil && error == nil {
                DispatchQueue.main.async {
                    self.nicknameLabel.text = NSLocalizedString("暱稱", comment: "") + ":" + (result?.nickname ?? "empty")
                    self.headPhotoImageView.image = result?.image
                }
            }
        }
    }
    
    @IBAction func logOutAction(_ sender: Any) {
                /*登出會員*/
        if APICaller.shared.mainAuth.currentUser != nil {
            APICaller.shared.currentUserSignOut { succeed, error in
                if !succeed {
                    print(error?.localizedDescription ?? "something error")
                    return
                } else {
                    DispatchQueue.main.async {
                        APICaller.shared.statusForReload = true
                        self.navigationController?.viewDidLoad()
                        UserDefaults.standard.removeObject(forKey: MyuserKey.nickname.rawValue)
                    }
                }
            }
        }
    }
}

