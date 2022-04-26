//
//  FollowPersistenceManager.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSaved
        case failedToFetchData
        case failedToDeleteData
    }
    
    static let shard = DataPersistenceManager()
    
    func followTitleWith(model: LiveStreamModel, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let item = TitleItem(context: context)
        
        item.head_photo = model.head_photo
        item.nickname = model.nickname
        item.stream_title = model.stream_title
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSaved))
        }
        /*
        let testNumber: Int?
        let head_photo: String?
        let nickname: String?
        let online_num: Int?
        let stream_title: String?
        let tags: String?*/
    }
    
    func fetchingFollowsFromDataBase(completion: @escaping(Result<[TitleItem],Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<TitleItem>
        request = TitleItem.fetchRequest()
        
        do {
            let model = try context.fetch(request)
            completion(.success(model))
            
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
            
        }
    }
    
    func deleteFollowWith(model: TitleItem, completion: @escaping(Result<Void,Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
            
        }
        
    }
}
