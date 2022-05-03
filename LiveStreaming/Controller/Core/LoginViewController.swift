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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var followsCollectionView: UICollectionView!
    
    private var follows: [TitleItem] = [TitleItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
//        self.title = NSLocalizedString("會員資訊", comment:"")
        backgroundImageView.image = UIImage(named: "paopao")
        backgroundImageView.layer.cornerRadius = 15
        backgroundImageView.layer.masksToBounds = true
        
        backgroundImageView.backgroundColor = .black
        headPhotoImageView.layer.cornerRadius = headPhotoImageView.frame.height / 2
        headPhotoImageView.layer.masksToBounds = true
        headPhotoImageView.layer.borderColor = UIColor.white.cgColor
        headPhotoImageView.layer.borderWidth = 1.5
        
        logoutButton.layer.cornerRadius = 20
        logoutButton.layer.masksToBounds = true
        
//        nicknameLabel.text = NSLocalizedString("暱稱", comment: "") + ":"
        accountLabel.text = NSLocalizedString("帳號", comment: "") + ":"
        
        self.showInfoFromFirebase()
       
        
        followsCollectionView.delegate = self
        followsCollectionView.dataSource = self
        followsCollectionView.register(UsersBarCollectionViewCell.self, forCellWithReuseIdentifier: UsersBarCollectionViewCell.identifier)
        followsCollectionView.backgroundColor = .clear
        self.fetchLoaclStorageForFollow()
        self.setBackgroundImage()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Follow"), object: nil, queue: nil) { _ in
            self.fetchLoaclStorageForFollow()
            self.setBackgroundImage()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DeleteFollow"), object: nil, queue: nil) { _ in
            self.fetchLoaclStorageForFollow()
            self.setBackgroundImage()
        }
        
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
//                    self.nicknameLabel.text = NSLocalizedString("暱稱", comment: "") + ":" + (result?.nickname ?? "empty")
                    self.nicknameLabel.text = result?.nickname ?? "empty"
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
    
    private func setBackgroundImage() {
        let model = self.follows.last
        if model != nil {
            let url = URL(string: model!.head_photo ?? "")
            let data = try? Data(contentsOf: url!)
            if data != nil {
                let image = UIImage(data: data!)
                if image != nil {
                    DispatchQueue.main.async {
                        self.backgroundImageView.image = image
                    }
                }
            }
        }
    }
}

extension LoginViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return follows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersBarCollectionViewCell.identifier, for: indexPath) as? UsersBarCollectionViewCell else {
            
            return UICollectionViewCell()
        }
        cell.configureFollows(model: self.follows[indexPath.row])
        return cell
    }
    
    private func fetchLoaclStorageForFollow() {
        DataPersistenceManager.shard.fetchingFollowsFromDataBase { [weak self] result in
            switch result {
            case .success(let follows):
                self?.follows = follows
                DispatchQueue.main.async {
                    self?.followsCollectionView.reloadData()
                    
                }
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
}

