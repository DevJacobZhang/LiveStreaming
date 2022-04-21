//
//  ViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/3/29.
//

import UIKit

class ViewController: UIViewController {
    
    private let fullScreenSize: CGSize! = UIScreen.main.bounds.size
    
    private var liveStreamModel = [LiveStreamModel]()
    
    var myCollectionView: MyCollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: CGFloat((UIScreen.main.bounds.width)-30) / 2, height: CGFloat((UIScreen.main.bounds.width)-30) / 2 )
        
        let collectionView = MyCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            MyCollectionViewCell.self,
            forCellWithReuseIdentifier: MyCollectionViewCell.identifier
        )
        collectionView.register(
            HeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderCollectionReusableView.identifier
        )
        return collectionView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
            
        APICaller.shared.getLiveStreamOfStreamlist { result in
            self.liveStreamModel = result
            self.myCollectionView.reloadData()
            
        }
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self

        self.view.addSubview(myCollectionView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        myCollectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)

        //登入狀態改變後，顯示此畫面時，將會顯示headerView或不顯示，取決於APICaller的StatusForReload狀態，登入成功或登出成功則會去改變這個布林值
        if APICaller.shared.statusForReload {
            DispatchQueue.main.async {
                self.myCollectionView.reloadData()
                APICaller.shared.statusForReload = false
            }
        }
    }
}

//MARK: - UICollectionViewDelegate  UICollectionViewDataSource  UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.liveStreamModel.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.configure(model: self.liveStreamModel[indexPath.row])
        
        cell.backgroundColor = UIColor.clear
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else {return}
        self.navigationController?.pushViewController(vc, animated: true)
        
 
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCollectionReusableView.identifier,
                for: indexPath) as! HeaderCollectionReusableView
            
            if let str = UserDefaults.standard.object(forKey: MyuserKey.nickname.rawValue) as? String {
                headerView.configure(withText: str)
            } else {
                headerView.configure(withText: "")
            }
            
            return headerView
        } else {
            return UICollectionReusableView()
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        var size = CGSize()

        if UserDefaults.standard.object(forKey: MyuserKey.nickname.rawValue) != nil {
            size = CGSize(width: self.view.bounds.width, height: 50)

        } else {
            size = CGSize(width: 0, height: 0)

        }
        return size
    }
    
}
