//
//  ChatPersistenceManager.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/12.
//

import Foundation
import UIKit

protocol ChatPersistenceManagerDelegate: NSObject {
    func getMessageFromServer(message: String?, error: Error?)
}


final class ChatPersistenceManager: NSObject {
    
    static let shard = ChatPersistenceManager()
    
    weak var delegate: ChatPersistenceManagerDelegate?
    
    private var webSocket: URLSessionWebSocketTask?
    
    func startConnectionToServer(userNameUrlStr: String) {
        
        let seesion = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            
        let url = URL(string: userNameUrlStr)
            webSocket = seesion.webSocketTask(with:url!)
            webSocket?.resume()
    }
    
    func send(message: String, completion: @escaping(Error?) -> Void) {
        var messageCheck = false
        for strChar in message.indices {
            let word = String(message[strChar])
            if word != " " {
                messageCheck = true
            }
        }
        if !messageCheck {
            return
        }
        
        let str = "{\"action\": \"N\",  \"content\": \"\(message)\"}"
        self.webSocket?.send(.string(str), completionHandler: { error in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    func receive() {
        webSocket?.receive(completionHandler: {[weak self] result in
            switch result{
            case .success(let message):
                switch message {
                case .data(let data):
                    print("got data : \(data)")
                case .string(let str):
                    self?.delegate?.getMessageFromServer(message: str, error: nil)
                    
                @unknown default:
                    break
                }
            case .failure(let error):
                self?.delegate?.getMessageFromServer(message: nil, error: error)
            }
            self?.receive()
        })
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "ended".data(using: .utf8))
    }
}
extension ChatPersistenceManager: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did cennect to server")
        receive()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did Close connection")
        
    }
}
