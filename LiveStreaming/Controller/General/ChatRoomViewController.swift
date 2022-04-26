//
//  ChatRoomViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/11.
//

import UIKit


class ChatRoomViewController: UIViewController, CustomAlertViewDelegate {

    
    private var keyboardStatus: Bool = false
    private var messageAllAry = [String]()
    private var usersBarArray = [String]()
    private let userIn = true, userOut = false
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
    
    let realcountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.alpha = 0.6
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.text = "在線人數："
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UsersBarCollectionViewCell.self, forCellWithReuseIdentifier: UsersBarCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let streamTitleView: StreamTitleView = {
        let view = StreamTitleView()
        view.alpha = 0.7
        view.backgroundColor = .black
        return view
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
        self.streamView.addSubview(tableView)
        
        self.streamView.addSubview(messageTextField)
        self.streamView.addSubview(sendMsgButton)
        self.streamView.addSubview(heartButton)
        self.streamView.addSubview(streamTitleView)
        self.streamView.addSubview(realcountLabel)
        
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
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
        
        streamTitleView.frame = CGRect(x: 10, y: 40, width: self.view.bounds.width / 2, height: 50)
        streamTitleView.layer.cornerRadius = 15
        streamTitleView.layer.masksToBounds = true
        
        realcountLabel.frame = CGRect(x: 10, y: streamTitleView.frame.height + streamTitleView.frame.origin.y + 10.0, width: 135, height: 40)
        configureButtonFrame()
        fadeOutViewAction(animation: true, alpha: 0.3)
        collectionView.frame = CGRect(x: self.view.frame.width / 2 + 50.0, y: 40, width: 150, height: 40)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        
        streamView.playRemove()
        streamView.removeFromSuperview()
    }

    private func configureButtonFrame() {
        //設定button的位子，以螢幕寬高來動態調節

        let width = self.view.bounds.width / 9.0 //button的大小
        let offsetX = self.view.bounds.width - (width * 2.0) //Ｘ位子
        let offsetY = self.view.bounds.height / 9.0 //Ｙ位子
        self.logoutButton.frame = CGRect(x: offsetX, y: offsetY, width: width, height: width)
        self.logoutButton.layer.cornerRadius = logoutButton.frame.width / 2
        
        self.messageTextField.layer.cornerRadius = 15
        self.messageTextField.layer.borderWidth = 2
        self.messageTextField.layer.masksToBounds = true
        self.messageTextField.backgroundColor = UIColor.black
        self.messageTextField.alpha = 0.7
        
        
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
    
    //MARK: - 配置左上角大標題的內容
    
    public func configure(photoUrlStr: String?, user: String, title: String?) {
        self.streamTitleView.configure(photoUrlStr:photoUrlStr ,user: user, title: title)
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
            print(error?.localizedDescription ?? "接收到訊息但無法解析正確")
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
                    usersBarUpdate(nickName: result.body.entry_notice?.username ?? "訪客", inOut: userIn)
                } else {
                    str = "  \(result.body.entry_notice?.username ?? "是誰？")：登出  "
                    usersBarUpdate(nickName: result.body.entry_notice?.username ?? "訪客", inOut: userOut)
                }
                self.messageAllAry.append(str)
                DispatchQueue.main.async {
                    self.realcountLabel.text = "在線人數：\(result.body.real_count ?? 0)"
                }
                
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

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ChatRoomViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersBarArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersBarCollectionViewCell.identifier, for: indexPath) as? UsersBarCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: usersBarArray[indexPath.row])
        return cell
    }
    
    private func usersBarUpdate(nickName: String, inOut: Bool) {
        if usersBarArray.count < 0 { return }
        if inOut {
            usersBarArray.append(nickName)
        } else {
            for index in 0 ..< usersBarArray.count {
                if usersBarArray[index] == nickName {
                    usersBarArray.remove(at: index)
                }
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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

