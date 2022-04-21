//
//  InfoViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/3/30.
//

import UIKit

/*
    MARK : SignIn Action, Button -> #1
    MARK : 帳號密碼偵錯功能 -> #2
    MARK : ALL Remenber Function -> #3
    MARK : TextField , Keyboard Action -> #4
 
*/

enum MyuserKey: String { //For Device ,UserDefalut Get Value
    case account = "Account"
    case password = "Password"
    case nickname = "nickname"
}

enum RemenberControll { //For Remenber Button Controll remove or remenber To UserDefault
    case remove
    case remenber
    
}

class InfoViewController: UIViewController {
    
    private var buttonStatus: Bool = false
    private let yesRemenber: Bool = true
    private let noRemenber: Bool = false
    
    let activityIndicator: UIActivityIndicatorView = {
        let ActivityIndicator = UIActivityIndicatorView(style: .large)
        ActivityIndicator.center = .zero
        ActivityIndicator.backgroundColor = UIColor.black
        ActivityIndicator.alpha = 0.8
        ActivityIndicator.layer.cornerRadius = 10
        ActivityIndicator.layer.masksToBounds = true
         return ActivityIndicator
    }()

    @IBOutlet weak var remenberButton: UIButton!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelAccount:UILabel = {
           let label = UILabel()
            label.text = " 帳號："
            label.textColor = .gray
            return label
        }()

        let barAppearance =  UINavigationBarAppearance()
        barAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        
        accountTextField.leftViewMode = .always
        accountTextField.leftView = labelAccount
        accountTextField.layer.cornerRadius = 15
        accountTextField.layer.masksToBounds = true
        accountTextField.layer.borderWidth = 1.5
        
        let labelPassword:UILabel = {
           let label = UILabel()
            label.text = " 密碼："
            label.textColor = .gray
            return label
        }()
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = labelPassword
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.layer.masksToBounds = true
        passwordTextField.layer.borderWidth = 1.5
        
        self.view.addSubview(activityIndicator)
        
            //firebase並沒有登入中，所以顯示輸入帳密的頁面
        if let account = UserDefaults.standard.value(forKey: MyuserKey.account.rawValue) as? String {
            accountTextField.text = account
            remenberStatusChanged(status: yesRemenber)
            if let password = UserDefaults.standard.value(forKey: MyuserKey.password.rawValue) as? String {
                //有記住帳號密碼
                passwordTextField.text = password
            }
        } else { //沒有記住帳號，同時直接就認定都沒有記住，避免使用者只記錄密碼，所以這邊偵測有密碼的話則清除！

            remenberStatusChanged(status: noRemenber)
                //檢查密碼，清除密碼
                
            if ((UserDefaults.standard.value(forKey: MyuserKey.password.rawValue)as? String) != nil) {
                    UserDefaults.standard.removeObject(forKey: MyuserKey.password.rawValue)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {   //didLoad >> willAppear >> didLayout
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

        activityIndicator.frame.size = CGSize(width: 150, height: 150)
        activityIndicator.center = self.view.center
        
        if buttonStatus == false { //按下登出後返回此畫面時，如果當初沒有按記住我，那這邊就要把textfield清空
            accountTextField.text = ""
            passwordTextField.text = ""
        }
    }
    
    // MARK: - SignIn Action, Button -> #1
    
    @IBAction func signInAction(_ sender: Any) {
        guard let accountEmail = accountTextField.text else {return}
        let checkError = checkString(account: accountEmail)
        if checkError != nil {
            showErrorLabel(errorStr: checkError!)
            return
        }
        guard let password = passwordTextField.text else {return}
        //執行登入
        activityIndicator.startAnimating()
        APICaller.shared.goToSignInFirebase(withEmail: accountEmail, password: password) { succeed, error in
            if succeed {
                //登入成功
                APICaller.shared.getCurrentUserInfo { result, error in
                    if result != nil {
                        UserDefaults.standard.set((result?.nickname!)!, forKey: MyuserKey.nickname.rawValue)
                        
                    }
                    DispatchQueue.main.async {
                        
                        APICaller.shared.statusForReload = true
                        self.tabBarController?.selectedIndex = 0
                       
                        self.navigationController?.viewDidLoad()
        
                        self.activityIndicator.stopAnimating()
                    }
                }
            } else {
                //登入失敗
                print(error?.localizedDescription ?? "just error")
                
                DispatchQueue.main.async {
                    
                    self.activityIndicator.stopAnimating()
                    
                }
            }
        }
    }
    
    //MARK: - 帳號偵錯，並顯示 -> #2
    //顯示錯誤訊息
    func showErrorLabel(errorStr: String) {
            
        let errorLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = UIColor.black
            label.alpha = 0.0
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.textColor = .white
            label.text = errorStr
            
            let width = self.view.bounds.width / 1.5
            let offsetX = width / 4
            
            label.frame = CGRect(x: offsetX, y: self.view.frame.height / 8, width: width, height: 40)
            label.text = errorStr
            return label
        }()
        self.view.addSubview(errorLabel)
        errorLabel.alpha = 0.8
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2.5, delay: 0) {
            errorLabel.alpha = 0
        }
    }
    
    //帳號密碼偵錯功能
    func checkString(account: String) -> String? {
        var numberOfStr = 0
        var testStr = ""
        if !(account.contains("@")) {
            return "不符合電子郵件格式"
        }
        for index in account.indices {
            let word = String(account[index])
            if word != " " {
                if word != "@" {
                    testStr += word
                    numberOfStr += 1
                } else {
                    break
                }
            } else {
                return "請勿輸入空白"
            }
        }
        if !(numberOfStr <= 20 && numberOfStr >= 4) {
            return "不符合的長度"
        }
        return nil
    }
    
    //密碼隱藏顯示
    @IBAction func secureAction(_ sender: UIButton) {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        if self.passwordTextField.isSecureTextEntry {
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    //MARK: - ALL Remenber Function -> #3
    
    @IBAction func remenberAction(_ sender: UIButton) {
        
        if !buttonStatus {
            self.remenberController(action: RemenberControll.remenber)
        } else {
            self.remenberController(action: RemenberControll.remove)
        }
        
    }
    func remenberController(action: RemenberControll) {
        
        switch action {
        case .remenber:
            let accountEmail = accountTextField.text
            let password = passwordTextField.text
            if accountEmail != "" && password != "" {
                UserDefaults.standard.set(accountEmail, forKey: MyuserKey.account.rawValue)
                UserDefaults.standard.set(password, forKey: MyuserKey.password.rawValue)
                remenberStatusChanged(status: yesRemenber)
            }
        case .remove:
            UserDefaults.standard.removeObject(forKey: MyuserKey.account.rawValue)
            UserDefaults.standard.removeObject(forKey: MyuserKey.password.rawValue)

            remenberStatusChanged(status: noRemenber)
        }
    }
    
    func remenberStatusChanged(status: Bool) {
        if status {
            //記住我
            self.remenberButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }else{
            //取消記住我
            self.remenberButton.setImage(UIImage(systemName: "square"), for: .normal)
            
        }
        buttonStatus = status
    }
    
    //MARK: - TextField , Keyboard Action -> #4
    
    @IBAction func didEndOnExit(_ sender: UITextField) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) //點擊螢幕收鍵盤
    }
    
}
