//
//  LiveStreamModel.swift
//  LiveStreaming
//
//  Created by Class on 2022/3/31.
//

import Foundation
import UIKit

//MARK: - For FirebaseDB

struct FirebaseDBInfo {
    var nickname: String?
    var image: UIImage?
}


//MARK: - For LiveStreamJSON

struct LiveStreamResponse: Codable {
    let result: CResult //命名Result會牴觸到Xcode底層的命名規則
}

struct CResult: Codable {
    let lightyear_list: [LiveStreamModel] //熱門推薦
    let stream_list: [LiveStreamModel] //首頁
}
struct LiveStreamModel: Codable {
    let testNumber: Int?
    let head_photo: String?
    let nickname: String?
    let online_num: Int?
    let stream_title: String?
    let tags: String?
    let streamer_id: Int?
}

//MARK: - For Chat Receive

struct GetMsgModel:Codable {
    let body: MsgBody
    let sender_role: Int
    
}

struct MsgBody:Codable {
    let chat_id: String?
    let nickname: String?
    let type: String?
    let text: String?
    let entry_notice: ActionStatus?//進入或離開
    let content: Language? //公告
    let real_count: Int?
}
struct ActionStatus: Codable {
    let username: String?
    let action: String?
}

struct Language: Codable {
    let cn: String? //簡體
    let en: String? //英文
    let tw: String? //繁體
}

