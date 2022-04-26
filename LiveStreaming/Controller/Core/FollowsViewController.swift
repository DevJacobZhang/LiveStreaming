//
//  FollowsViewController.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit

class FollowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var follows: [TitleItem] = [TitleItem]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .blue
        tableView.register(FollowsTableViewCell.self, forCellReuseIdentifier: FollowsTableViewCell.identifier)
        return tableView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Follows", comment: "")
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        fetchLoaclStorageForFollow()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Follow"), object: nil, queue: nil) { _ in
            self.fetchLoaclStorageForFollow()
        }
    }
    
    private func fetchLoaclStorageForFollow() {
        DataPersistenceManager.shard.fetchingFollowsFromDataBase { [weak self] result in
            switch result {
            case .success(let follows):
                self?.follows = follows
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = self.view.frame
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return follows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowsTableViewCell.identifier, for: indexPath) as? FollowsTableViewCell else {
            return UITableViewCell()
        }
        print("\(follows[indexPath.row].nickname ?? "coreData沒有資料？")")
        cell.configure(model: follows[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            DataPersistenceManager.shard.deleteFollowWith(model: follows[indexPath.row]) { result in
                switch result {
                case .success():
                    print("Deleted from the database")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.follows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
}
