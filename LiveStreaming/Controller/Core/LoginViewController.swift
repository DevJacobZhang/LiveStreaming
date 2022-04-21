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
        self.title = "會員資訊"
        
        headPhotoImageView.layer.cornerRadius = headPhotoImageView.frame.height / 2
        headPhotoImageView.layer.masksToBounds = true
//        headPhotoImageView.contentMode = .scaleToFill
        
        logoutButton.layer.cornerRadius = 20
        logoutButton.layer.masksToBounds = true
        
        nicknameLabel.text = "暱稱："
        accountLabel.text = "帳號："
        
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
        self.accountLabel.text = "帳號：\(userAccount)"
        APICaller.shared.getCurrentUserInfo { result, error in
            if result != nil && error == nil {
                DispatchQueue.main.async {
                    self.nicknameLabel.text = "暱稱：\(result?.nickname ?? "empty")"
                    self.headPhotoImageView.image = result?.image

                }
            }
        }
        
    }
    
    @IBAction func logOutAction(_ sender: Any) {
                /*登出會員*/
        if APICaller.shared.mainAuth.currentUser != nil {
            do {
                try APICaller.shared.mainAuth.signOut()
                APICaller.shared.statusForReload = true

                self.navigationController?.viewDidLoad()
                
                UserDefaults.standard.removeObject(forKey: MyuserKey.nickname.rawValue)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}

