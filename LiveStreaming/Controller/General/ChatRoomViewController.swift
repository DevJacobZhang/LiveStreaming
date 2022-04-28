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
    
    var giftAry: [String] = ["火車", "飛機", "火箭", "跑車", "罐頭塔", "UFO", "特斯拉", "保時捷", "勞力士"]
    /////////////////////用來設定GiftCollection禮物列的位子以及定位用的
    private var originCollectionViewX = 0.0
    private var openStatusX = 0.0
    private var giftOpenStatus: Bool = false
    /////////////////////////////////////////////////////////////
    
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
        label.textColor = .white
        label.backgroundColor = UIColor(red: 131/255, green: 175/255, blue: 155/255, alpha: 1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.text = "在線人數："
        return label
    }()
    
    private let usersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UsersBarCollectionViewCell.self, forCellWithReuseIdentifier: UsersBarCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let giftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(GiftCollectionViewCell.self, forCellWithReuseIdentifier: GiftCollectionViewCell.identifier)
        collection.backgroundColor = .clear
        return collection
    }()
    
    private let streamTitleView: StreamTitleView = {
        let view = StreamTitleView()
        view.alpha = 0.7
        view.backgroundColor = .black
        return view
    }()
    
    private let arrowView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "arrowshape.turn.up.left")
        view.backgroundColor = .clear
        view.tintColor = .white
        view.contentMode = .scaleAspectFill
        view.alpha = 0.4
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addKeyboardObserver()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        
        streamView.isUserInteractionEnabled = true
        streamView.addGestureRecognizer(panGestureRecognizer)
        
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
        
        self.view.addSubview(usersCollectionView)
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        
        self.view.addSubview(giftCollectionView)
        giftCollectionView.delegate = self
        giftCollectionView.dataSource = self
        
        originCollectionViewX = self.view.frame.width //11 pro = 375.0
        openStatusX = self.view.frame.width - 80.0
        
        self.view.addSubview(arrowView)
        
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
        let width = self.view.bounds.width - (self.view.bounds.width / 2 + 50)
        usersCollectionView.frame = CGRect(x: self.view.frame.width / 2 + 50.0, y: 40, width: width, height: 40)
        giftCollectionView.frame = CGRect(x: originCollectionViewX, y: 200, width: 80, height: 350)
        arrowView.frame.size = CGSize(width: 40, height: 40)
        arrowView.frame.origin = CGPoint(x: self.view.bounds.width - 60, y: self.view.bounds.height / 2 - 30)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        usersBarArray.removeAll()
        
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
    
    //MARK: - 點擊螢幕滑動來顯示GiftCollectionView
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        
        let translation: CGPoint = sender.translation(in: streamView)
        if giftOpenStatus { // 禮物列打開時，根據現在的位子去做加減X
            let offsetX = openStatusX + translation.x
            self.giftCollectionView.frame.origin.x = offsetX
            self.arrowView.frame.origin.x = offsetX - 40.0
            
        } else {//禮物列關閉時，根據畫面最右邊的X去做加減
            let offsetX = originCollectionViewX + translation.x
            self.giftCollectionView.frame.origin.x = offsetX
            self.arrowView.frame.origin.x = offsetX - 40.0
        }
        
        if sender.state == .ended { //放開手指時，如果x邊左就代表開啟禮物列，太右邊就關掉
            if self.giftCollectionView.frame.origin.x <= (self.originCollectionViewX - 40) {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
                    self.giftCollectionView.frame.origin.x = self.originCollectionViewX - self.giftCollectionView.frame.width
                    self.arrowView.frame.origin.x = self.giftCollectionView.frame.origin.x - 40.0
                    self.giftOpenStatus = true
                    self.arrowView.alpha = 0.0
                    
                }
            } else {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
                    self.giftCollectionView.frame.origin.x = self.originCollectionViewX
                    self.arrowView.frame.origin.x = self.originCollectionViewX - 40.0
                    self.giftOpenStatus = false
                    self.arrowView.alpha = 0.4
                    
                }
            }
        }
    }
    
    //MARK: - 配置左上角大標題的內容
    
    public func configure(liveStreamModel: LiveStreamModel?) {
        if liveStreamModel != nil {
            self.streamTitleView.configure(liveStreamModel: liveStreamModel!)
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

//MARK: - 點擊禮物觸發delegate

extension ChatRoomViewController: GiftCollectionViewCellDelegate {
    func didTapGiftWith(giftTag: Int) {
        print("送出禮物:\(giftTag)")
        let controller = UIAlertController(title: "確定送出\"\(giftAry[giftTag])\"嗎", message: "主播會很開心的唷", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "當然", style: .default){ _ in
            
        }
        let cancelAction = UIAlertAction(title: "沒錢", style: .cancel, handler: nil)
        
        controller.addAction(cancelAction)
        controller.addAction(okAction)

        present(controller, animated: true, completion: nil)
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

//MARK: - \UsersBar\ \Gift\ UICollectionViewDelegate, UICollectionViewDataSource

extension ChatRoomViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.usersCollectionView {
            //是userCollection
            return 1
        } else if collectionView == self.giftCollectionView {
            //是giftCollection
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.usersCollectionView {
            return usersBarArray.count
        } else if collectionView == self.giftCollectionView {
            return giftAry.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.usersCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersBarCollectionViewCell.identifier, for: indexPath) as? UsersBarCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(text: usersBarArray[indexPath.row])
            return cell
        } else if collectionView == self.giftCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiftCollectionViewCell.identifier, for: indexPath) as? GiftCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(giftNumber: indexPath.row, giftName: giftAry[indexPath.row])
            cell.delegate = self
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    private func usersBarUpdate(nickName: String, inOut: Bool) {
        if usersBarArray.count < 0 { return }
        if inOut {
            usersBarArray.append(nickName)
        } else {
            for index in 0 ..< usersBarArray.count {

                if usersBarArray[index] == nickName {
                    
                    usersBarArray.remove(at: index)
                    break
                }
            }
        }
        DispatchQueue.main.async {
            self.usersCollectionView.reloadData()
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

