//
//  SearchResultsViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/2.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidTapItem(liveStreamModel: LiveStreamModel)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultsViewControllerDelegate?
    
    public var resultliveStreamModel = [LiveStreamModel]() //搜尋結果
    
    var liveStreamModel = [LiveStreamModel]() //原本的熱門推薦
    
    
    public var myCollectionView: MyCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: CGFloat((UIScreen.main.bounds.width)-30) / 2, height: CGFloat((UIScreen.main.bounds.width)-30) / 2 )
        
        let collectionView = MyCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        return collectionView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(myCollectionView)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myCollectionView.frame = view.bounds
    }

}

//MARK: - UICollectionViewDelegate   UICollectionViewDataSource

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (section == 0) ? self.resultliveStreamModel.count : self.liveStreamModel.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as? MyCollectionViewCell else {
            
            return UICollectionViewCell()
        }
        if indexPath.section == 0 {
            
            cell.configure(model: self.resultliveStreamModel[indexPath.row])
            return cell

        } else {
            
            cell.configure(model: self.liveStreamModel[indexPath.row])
            return cell
        }
            
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            self.delegate?.searchResultsViewControllerDidTapItem(liveStreamModel: self.resultliveStreamModel[indexPath.row])

        } else {
            self.delegate?.searchResultsViewControllerDidTapItem(liveStreamModel: self.liveStreamModel[indexPath.row])

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCollectionReusableView.identifier,
                for: indexPath) as! HeaderCollectionReusableView
            
            if indexPath.section == 0 {
                let localizationString = NSLocalizedString("搜尋結果", comment: "")
                headerView.configureSearchResult(withTitle: localizationString)
            } else {
                let localizationString = NSLocalizedString("熱門推薦", comment: "")
                headerView.configureSearchResult(withTitle: localizationString)
            }
            return headerView
        } else {
            return UICollectionReusableView()
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        var size = CGSize()
        size = CGSize(width: self.view.bounds.width, height: 50)

        return size
    }
}
    

