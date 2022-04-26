//
//  FollowsViewController.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit

class FollowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let testAry = ["妹子", "女神", "女孩", "女高中生", "女大學生"]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .blue
        tableView.register(FollowsTableViewCell.self, forCellReuseIdentifier: FollowsTableViewCell.identifier)
        return tableView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = self.view.frame
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowsTableViewCell.identifier, for: indexPath) as? FollowsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(text:testAry[indexPath.row])
        return cell
    }
}
