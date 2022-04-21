//
//  SearchViewController.swift
//  LiveStreaming
//
//  Created by Class on 2022/3/30.
//

import UIKit

class SearchViewController: UIViewController {

    private var liveStreamModel = [LiveStreamModel]()
    
    private var searchTextMark = "" //拿來避免重複按下searchBar的畫面閃爍
    
    var myCollectionView: MyCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: CGFloat((UIScreen.main.bounds.width)-30) / 2, height: CGFloat((UIScreen.main.bounds.width)-30) / 2 )
        
        let collectionView = MyCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader , withReuseIdentifier: HeaderCollectionReusableView.identifier)
        
        return collectionView
        
    }()
    
    var mySearchBarController: UISearchController = {
        let searchBar = UISearchController(searchResultsController:SearchResultsViewController() )
        searchBar.searchBar.placeholder = "Search"
        searchBar.searchBar.searchBarStyle = .default
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        APICaller.shared.getLiveStreamModel { result in
            DispatchQueue.main.async {
                self.liveStreamModel = result
                self.myCollectionView.reloadData()
            }
        }
        
        addKeyboardObserver()
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        self.view.addSubview(myCollectionView)
        
        navigationItem.searchController = mySearchBarController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        mySearchBarController.searchResultsUpdater = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myCollectionView.frame = CGRect(x: 0, y: 30, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

//MARK: -UICollectionViewDelegate UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return liveStreamModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as? MyCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        cell.configure(model: self.liveStreamModel[indexPath.row])
        
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
            
            headerView.configureSearchResult(withTitle: "熱門推薦")
            
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

//MARK: - UISearchResultsUpdating     //SearchResultsViewControllerDelegate 這是搜尋結果出現的VC，點擊cell回傳delegate事件，並由此處掛上直播間，而不是在搜尋結果的VC掛上直播間

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = mySearchBarController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 1,
              let resultController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        //先判斷使用者是不是已經輸入字，往下查找，當找不到時，再度點擊searchBar要進行輸入搜尋字串的瞬間，
        //去避免searchResultController又掛上一個VC，這個偵測的TextMark在鍵盤收起時會紀錄下來
        if query == searchTextMark { return }
        
        var searchResult = [LiveStreamModel]()
        
        for searchSome in self.liveStreamModel {
            if searchSome.nickname!.localizedCaseInsensitiveContains(query) || searchSome.tags!.localizedCaseInsensitiveContains(query) || searchSome.stream_title!.localizedCaseInsensitiveContains(query) {
                
                searchResult.append(searchSome)
            }
        }
        
        resultController.delegate = self //callback delegate for didTapCell
        resultController.resultliveStreamModel = searchResult
        resultController.liveStreamModel = self.liveStreamModel
        
        resultController.myCollectionView.reloadData()
    }
    
    func searchResultsViewControllerDidTapItem(liveStreamModel: LiveStreamModel)
    {
        print("get searchResult.delegate")
        DispatchQueue.main.async {
            guard let vc = self.storyboard!.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - 鍵盤收起事件：記錄使用者按下搜尋按鈕並記錄搜尋bar的文字，可以讓updater避免在同樣的文字時反覆掛ＶＣ
    
    func addKeyboardObserver() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
            print("keyboardHide")
        self.searchTextMark = mySearchBarController.searchBar.text ?? ""
    
    }
}
