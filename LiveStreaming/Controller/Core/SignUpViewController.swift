//
//  SignUpViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/4.
//

import UIKit
import SwiftUI

class SignUpViewController: UIViewController, APICallerDelegateOfCreate {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var editHeadPhoto: UIButton!

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var signUpImageView: UIImageView!
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let activityIndicator: UIActivityIndicatorView = {
        let ActivityIndicator = UIActivityIndicatorView(style: .large)
        ActivityIndicator.center = .zero
        ActivityIndicator.backgroundColor = UIColor.black
        ActivityIndicator.alpha = 0.8
        ActivityIndicator.layer.cornerRadius = 10
        ActivityIndicator.layer.masksToBounds = true
         return ActivityIndicator
    }()
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.title = "註冊會員"
        
        activityIndicator.center = self.view.center
        let width = self.view.bounds.size.width / 2
        
        activityIndicator.bounds.size = CGSize(width: width, height: width)
        self.view.addSubview(activityIndicator)
        
        signUpImageView.layer.cornerRadius = signUpImageView.frame.height / 2
        signUpImageView.layer.masksToBounds = true
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        
        nickNameTextField.layer.cornerRadius = 10
        nickNameTextField.layer.masksToBounds = true
        nickNameTextField.layer.borderWidth = 1
        
        accountTextField.layer.cornerRadius = 10
        accountTextField.layer.masksToBounds = true
        accountTextField.layer.borderWidth = 1
        
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.masksToBounds = true
        passwordTextField.layer.borderWidth = 1
        
        imagePickerController.delegate = self
        
        APICaller.shared.delegateOfCreate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
  
    @IBAction func signUpAction(_ sender: Any) {
        self.view.endEditing(true)
        let nickname = nickNameTextField.text ?? ""
        if nickname == "" {
            showErrorLabel(errorStr: "請輸入暱稱")
            
            return
        }
        
        let accountEmail = accountTextField.text ?? ""
        if accountEmail == "" {
            showErrorLabel(errorStr: "請輸入帳號")
            return
        }

        let password = passwordTextField.text ?? ""
        if password == "" {
            showErrorLabel(errorStr: "請輸入密碼")
            return
        }

        
        
        let resultStr = checkString(account: accountEmail, password: password)
        if resultStr != nil {
            showErrorLabel(errorStr: resultStr!)
            return
        }
        
        activityIndicator.startAnimating()

        let info = FirebaseDBInfo(nickname: nickname, image: self.signUpImageView.image)
        APICaller.shared.goToCreatUser(email: accountEmail, password: password, otherInfo: info)
        //will get APICaller Delegate func to stop Animation & popViewController
        
            
    }
   
    //MARK: - 帳號密碼偵錯，並顯示
    
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
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3, delay: 0) {
            errorLabel.alpha = 0
        }
    }
    
    //帳號密碼偵錯功能
    func checkString(account: String, password: String) -> String? {
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
            return "帳號不符合長度"
        }
        
        // 密碼檢查
        
        if password.contains(" ") {
            return "密碼請勿含有空白"
        }
        
        numberOfStr = password.count
        if !(numberOfStr <= 12 && numberOfStr >= 6) {
            return "密碼不符合長度"
        }
        
        return nil
    }
    
    @IBAction func editHeadPhotoAction(_ sender: Any) {
        let alert = UIAlertController(title: "編輯大頭貼", message: "請選擇一項來設定大頭貼", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { (_) in
                    self.cameraGo()
                }))

                alert.addAction(UIAlertAction(title: "相簿圖庫", style: .default, handler: { (_) in
                    self.albumLibaryGo()
                }))


                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                    print("User click Dismiss button")
                }))

                self.present(alert, animated: true, completion: {
                    print("completion block")
                })
        
    }
    func cameraGo() {
        print("Camera")
        self.imagePickerController.sourceType = .camera
        self.imagePickerController.allowsEditing = true
        present(self.imagePickerController, animated: true)
    }
    func albumLibaryGo() {
        print("photoLibary")
        
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.allowsEditing = false
        self.present(self.imagePickerController, animated: true)
        
        
    }
    
    
    
    //MARK: - APICaller.Delegate Func Here
    
    func creatUserTaskDone() {
        self.activityIndicator.stopAnimating()
        self.navigationController?.popViewController(animated: true)

    }
    func creatUserTaskCursh() {
        self.activityIndicator.stopAnimating()
    }
}

 //MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        guard let image = info[.originalImage] as? UIImage else {
            print("no image")
            return
        }
        
        self.signUpImageView.image = image
        picker.dismiss(animated: true)
    }
}

 //MARK: - addKeyboardObserver when Hide & Show , change view.Y軸

extension SignUpViewController {
    func addKeyboardObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {

        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            view.frame.origin.y = -keyboardHeight + 100.0
        } else {
            view.frame.origin.y = -view.frame.height / 3
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        view.frame.origin.y = 0
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) //點擊螢幕收鍵盤
    }
    
    @IBAction func didEndOnExit(_ sender: Any) {
        //點擊結束按鈕
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
