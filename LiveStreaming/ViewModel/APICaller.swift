//
//  APICaller.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/2.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

// MARK: - Error For Func
enum CurrentUserError: Error{
    case UserNotFound
}

struct Constants {
//    static let baseURL = Bundle.main.url(forResource: "myTestJsonFile", withExtension: "json")
    static let path = Bundle.main.path(forResource: "myTestJsonFile", ofType: "json")
}

//MARK: - For CreateUser "SignUpViewController" Use

protocol APICallerDelegateOfCreate: AnyObject {
    func creatUserTaskDone()
    func creatUserTaskCursh()
    
}

class APICaller {
    
    weak var delegateOfCreate: APICallerDelegateOfCreate?
    
    static let shared = APICaller()
    
    let mainAuth = Auth.auth()
    
    public var statusForReload = false //For ViewController ReloadData Use
    
    //熱門推薦
    func getLiveStreamModel(completionHandler: @escaping ([LiveStreamModel])-> Void) {
        
        let url = URL(fileURLWithPath: Constants.path!)
        var model = [LiveStreamModel]()
        do {
            
            let data = try Data.init(contentsOf: url)
            let result = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
            model = result.result.lightyear_list
            completionHandler(model)
            
        } catch {
            print("data try error")
        }
    }
    //首頁
    func getLiveStreamOfStreamlist(completionHandler: @escaping ([LiveStreamModel])-> Void) {
        let url = URL(fileURLWithPath: Constants.path!)
        var model = [LiveStreamModel]()
        do {
            
            let data = try Data.init(contentsOf: url)
            let result = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
            model = result.result.stream_list
            completionHandler(model)
            
        } catch {
            print("data try error")
        }
    }
    
    //創建firebase帳密
    func goToCreatUser(email: String, password: String, otherInfo: FirebaseDBInfo?) {
        mainAuth.createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                self.delegateOfCreate?.creatUserTaskCursh()
                
            }
            if error == nil && result != nil{
                //成功創建帳號
                self.delegateOfCreate?.creatUserTaskDone()
                //去除掉/@後面的字，將前面取出來當作userAcount，以便到DB創建資料夾，以及取資料夾內部資料
                var userAccount = ""
                let strOfEmail = email

                for index in strOfEmail.indices {

                    let word = String(strOfEmail[index])
                    if word != "@" {
                        userAccount += word
                    } else {
                        break
                    }
                }                //userAccount創建完畢

                let storage = Storage.storage().reference() //開啟storage儲存照片的地方

                if otherInfo?.image != nil { //使用者有設定要當作大頭貼的照片

                    //有大頭貼要儲存到storage，所以要生成url存到ＤＢ以及nickname,account
                    
                    let imageData = otherInfo?.image!.jpegData(compressionQuality: 0.5)//轉成data格式
                    let path = "images/\(UUID().uuidString).jpg"//生成到時候取得照片的路徑名稱
                    let fileRef = storage.child(path) //以path的名稱到 storage的儲存空間儲存這張照片，名稱就是path

                    fileRef.putData(imageData!, metadata: nil) { metadata, error in
                        //開始到storage空間儲存照片
                        if error == nil && metadata != nil {
                            //儲存成功，接下來...
                            //將照片儲存到storage後進行開啟DB儲存URL連結，nickname,account
                            if otherInfo != nil {
                                let db = Firestore.firestore() //DB
                                let urlPath = path //到時候取的storage裡面image的絕對路徑，放在帳號的DB裡面
                                let nickname = otherInfo?.nickname ?? "empty"
                                let account = userAccount
                                //以userAccount為資料夾名稱到DB創建一個資料夾，內容包含以下三個
                                db.collection(userAccount).document().setData(["url":urlPath,"nickname":nickname,"account":account])
                            }
                        }
                    }
                } else {
                    //沒大頭貼要儲存，所以只要儲存nickname,account到DB
                    if otherInfo != nil {
                        let nickname = otherInfo?.nickname ?? "empty"
                        let account = userAccount
                        
                        let db = Firestore.firestore()
                        db.collection(userAccount).document().setData(["nickname":nickname,"account":account])

                    }
                }
            }// if error == nil && result != nil end
            DispatchQueue.main.async {
                do {
                    try self.mainAuth.signOut()//firebase在註冊後會自動登入！所以註冊完後登出。

                } catch {
                    print("error logout")
                }
            }
        }// Auth.auth().createUser end
    }//func end
   
    func currentUserSignOut(completion: @escaping(Bool,Error?) -> Void) {
        
        do {
            try self.mainAuth.signOut()
            completion(true, nil)
        } catch {
            completion(false,error)
        }
    }
    
    //取得使用者資訊
    func getCurrentUserInfo(completionHandler:@escaping (FirebaseDBInfo?, Error?) -> Void) {
        guard let user = mainAuth.currentUser else {
            completionHandler(nil,CurrentUserError.UserNotFound)
            return
        }
        guard let strOfEmail = user.email else {
            completionHandler(nil,CurrentUserError.UserNotFound)
            return
        }
        
        var userInfo = FirebaseDBInfo()
        
        var userAccount = ""
        
        for index in strOfEmail.indices {
        
            let word = String(strOfEmail[index])
        
            if word != "@" {
                userAccount += word
            } else {
                break
            }
        }
        let db = Firestore.firestore()
        db.collection(userAccount).getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                var paths = [String]()
                
                for doc in snapshot!.documents {
                    paths.append(doc["url"] as! String)
                    userInfo.nickname = doc["nickname"] as? String
                    
                }
                
                for path in paths { //這裡是儲存image的照片路徑名稱，取得名稱之後再利用迴圈去storage找出照片（基本上只有一個，所以迴圈應該只跑一次？？？）
                    
                    let storageRef = Storage.storage().reference()
                    let fileRef = storageRef.child(path) //這裏path應該是在firebase網頁裡面storage的image/uuid.jpg，然後把這一串弄到storage裡面找
                    
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in //限制大小是5MB
                        
                        if error == nil && data != nil {
                            let image = UIImage(data: data!)
                            userInfo.image = image
                            completionHandler(userInfo, nil)
                            
                        }
                    } //fileRef.getData(maxSize: 5 * 1024 * 1024)
                } //for path in paths
            }//if error == nil && snapshot != nil
        }//db.collection(userAccount).getDocuments
        
    }//func end
    
    //登入帳號密碼返回成功或失敗
    func goToSignInFirebase(withEmail: String, password: String, completionHandler: @escaping(Bool,Error?)->Void) {
        mainAuth.signIn(withEmail: withEmail, password: password) { result, error in
            if error == nil {
                completionHandler(true,nil)
            } else {
                completionHandler(false,error)
            }
        }
    }
    
}
