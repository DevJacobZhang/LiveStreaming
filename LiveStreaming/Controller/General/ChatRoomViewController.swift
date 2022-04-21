//
//  ChatRoomViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/11.
//

import UIKit



class ChatRoomViewController: UIViewController, UITextFieldDelegate, CustomAlertViewDelegate {

    

    private var webSocket: URLSessionWebSocketTask?

    private var keyboardStatus: Bool = false
    
    private var messageAllAry = [String]()
    @IBOutlet weak var heartButton: UIButton!
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMsgButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let streamView: StreamView = {
        let view = StreamView()
        return view
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logout"), for: .normal)
        button.backgroundColor = UIColor.black
        button.alpha = 0.7
        button.addTarget(nil, action: #selector(logoutAction), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    
    let logoutAlertView: CustomAlertView = {
        let view = CustomAlertView()
        return view
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.black
        label.alpha = 0.7
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.text = "first error"
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObserver()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        
        self.view.addSubview(streamView)
        
        self.streamView.addSubview(logoutButton)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.register(UINib(nibName: "ChatLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatLabelTableViewCell")
        self.streamView.addSubview(self.tableView)
        
        self.streamView.addSubview(self.messageTextField)
        messageTextField.delegate = self
        
        self.streamView.addSubview(self.sendMsgButton)
        self.streamView.addSubview(self.heartButton)
        
        ChatPersistenceManager.shard.delegate = self
        /*------------------------------// start webSocket//-----------------------------------*/
        
        APICaller.shared.getCurrentUserInfo(completionHandler: { result, error in
            var userName: String?
            if result != nil && error == nil {
                userName = result?.nickname!
                
            } else {
                userName = "訪客"
            }
            DispatchQueue.main.async {
                let str = "wss://client-dev.lottcube.asia/ws/chat/chat:app_test?nickname=\(userName!)"
                let strAfter = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ChatPersistenceManager.shard.startConnectionToServer(userNameUrlStr: strAfter!)
            }
            
        })
        /*------------------------------// end webSocket//-----------------------------------*/
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.streamView.frame = self.view.bounds
        
        configureButtonFrame()
        fadeOutViewAction(animation: true, alpha: 0.3)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        
        streamView.playRemove()
        streamView.removeFromSuperview()
        
    }
    
    
    func configureButtonFrame() {
        //設定button的位子，以螢幕寬高來動態調節

        let width = self.view.bounds.width / 9.0 //button的大小
        let offsetX = self.view.bounds.width - (width * 2.0) //Ｘ位子
        let offsetY = self.view.bounds.height / 10.0 //Ｙ位子
        self.logoutButton.frame = CGRect(x: offsetX, y: offsetY, width: width, height: width)
        self.logoutButton.layer.cornerRadius = logoutButton.frame.width / 2
        
        self.messageTextField.layer.cornerRadius = 15
        self.messageTextField.layer.borderWidth = 2
        self.messageTextField.layer.masksToBounds = true
        self.messageTextField.backgroundColor = UIColor.black
        self.messageTextField.alpha = 0.7
        
        
        // 依據textfield的位子 動態調整sendButton在右方剩餘空間當中處於置中位子
        let sendButtonWidth = self.messageTextField.frame.size.height
    
        let remainingSpace = self.view.frame.width - (self.messageTextField.frame.origin.x + self.messageTextField.frame.size.width)//剩餘空間
        
        let sendButtonOffsetX = self.messageTextField.frame.origin.x + self.messageTextField.frame.size.width + remainingSpace / 2
        
        let center = CGPoint(x:sendButtonOffsetX, y: self.messageTextField.bounds.size.height / 2 + self.messageTextField.frame.origin.y)
        self.sendMsgButton.center = center
        
        self.sendMsgButton.frame.size = CGSize(width: sendButtonWidth, height: sendButtonWidth)//textfield多高，按鈕的寬高就等於多少
        
        self.sendMsgButton.layer.cornerRadius = self.sendMsgButton.frame.width / 2
        self.sendMsgButton.layer.masksToBounds = true
        
        
       
    }
    
    @objc func logoutAction() {
        self.logoutAlertView.delegate = self
        self.logoutAlertView.frame = self.view.bounds
        self.view.addSubview(self.logoutAlertView)
    }
    
    func userDidTapLeaveButton(leave: Bool) {
        if leave {
            self.logoutAlertView.removeFromSuperview()
            ChatPersistenceManager.shard.close()
            
            self.navigationController?.popViewController(animated: true)
        } else {
            self.logoutAlertView.removeFromSuperview()
        }
    }
    
    @IBAction func sendMsgAction(_ sender: Any) {
        if self.messageTextField.text != "" && self.messageTextField.text != nil {
            let text = self.messageTextField.text!
            ChatPersistenceManager.shard.send(message: text) { error in
                if error != nil {
                    print("傳送訊息失敗")
                }
            }
            self.messageTextField.text = ""
        }
        
    }
    
    //MARK: - 聊天室淡出效果
    
    private func fadeOutViewAction(animation: Bool, alpha: CGFloat) {
        
        if animation {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2.5, delay: 1.5, options: .allowUserInteraction) {
                self.tableView.alpha = alpha
                self.messageTextField.alpha = alpha
                self.sendMsgButton.alpha = alpha
            }
        } else {
            self.tableView.alpha = 1
            self.messageTextField.alpha = alpha
            self.sendMsgButton.alpha = alpha
        }
        
    }
    
    //MARK: - 愛心動畫
    
    @IBAction func heartAction(_ sender: Any) {
        let imageV: UIImageView = {
            let imgV = UIImageView()
            imgV.image = UIImage(systemName: "heart.fill")
            imgV.tintColor = .systemPink
            imgV.frame = CGRect(x: self.heartButton.frame.origin.x, y: self.heartButton.frame.origin.y-10, width: 50, height: 50)
            imgV.backgroundColor = .clear
            return imgV
        }()
        self.view.addSubview(imageV)
        let offsetX = CGFloat(randomIn(min: -100, max: 100))
        
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2.5, delay: 0) {
            imageV.frame.origin = CGPoint(x: imageV.frame.origin.x + offsetX, y: 0)
            imageV.alpha = 0
        }
    }
    //隨機產生[範圍]數字回傳
    func randomIn(min: Int, max: Int) -> Int {
        return Int(arc4random()) % (max - min + 1) + min
        
    }
}

//MARK: - UITableViewDelegate UITableViewDataSource

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageAllAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLabelTableViewCell", for: indexPath) as! ChatLabelTableViewCell
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        let index = messageAllAry.count - 1 - indexPath.row
        cell.configure(msgText: messageAllAry[index])
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

//MARK: - 從ChatPersistenceManagerDelegate收到的資訊

extension ChatRoomViewController: ChatPersistenceManagerDelegate {
    func getMessageFromServer(message: String?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription)
            return
        }
        getInfoMsgStringFromServer(jsonString: message!)
    }
}
//MARK: - 將從server收到的string放到這裡去執行轉Data，在用Json+Model解檔，取得是什麼訊息之後加到messageAllAry，再reloadData顯示到聊天室table上
extension ChatRoomViewController {

    func getInfoMsgStringFromServer(jsonString:String){

        let jsonData: Data = jsonString.data(using: .utf8)!
        
        do {
            let result = try JSONDecoder().decode(GetMsgModel.self, from: jsonData)
            let senderRole = result.sender_role
            if senderRole == 0 { //代表有人進出
                
                var str = ""
                if result.body.entry_notice?.action! == "enter" {
                    str = "  \(result.body.entry_notice?.username ?? "是誰？")：登入  "
                } else {
                    str = "  \(result.body.entry_notice?.username ?? "是誰？")：登出  "
                }
                self.messageAllAry.append(str)
                
            }else if senderRole == -1 {// -1代表觀看者的發話
                let str = "  \(result.body.nickname ?? "test?")：\(result.body.text ?? "?")  "
                self.messageAllAry.append(str)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.messageAllAry.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: - addKeyboardObserver when Hide & Show , change view.Y軸

extension ChatRoomViewController {
   func addKeyboardObserver() {
       
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   
   @objc func keyboardWillShow(notification: Notification) {
       fadeOutViewAction(animation: false, alpha: 0.7)
       if keyboardStatus == true {
           return
       }
       keyboardStatus = true
       if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRect = keyboardFrame.cgRectValue
           let keyboardHeight = keyboardRect.height
           
           self.tableView.frame.origin.y -= keyboardHeight
           self.messageTextField.frame.origin.y -= keyboardHeight
           self.sendMsgButton.frame.origin.y -= keyboardHeight
           self.heartButton.frame.origin.y -= keyboardHeight
       } else {
//           self.tableView.frame.origin.y = -view.frame.height / 3
       }
   }
   
   @objc func keyboardWillHide(notification: Notification) {
       fadeOutViewAction(animation: true, alpha: 0.3)
       
       if keyboardStatus == false {
            return
       }
       keyboardStatus = false
       if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRect = keyboardFrame.cgRectValue
           let keyboardHeight = keyboardRect.height
           self.tableView.frame.origin.y += keyboardHeight
           self.messageTextField.frame.origin.y += keyboardHeight
           self.sendMsgButton.frame.origin.y += keyboardHeight
           self.heartButton.frame.origin.y += keyboardHeight
       }
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       view.endEditing(true) //點擊螢幕收鍵盤
   }

    @IBAction func didEndOnExit(_ sender: Any) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
