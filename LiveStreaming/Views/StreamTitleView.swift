//
//  StreamTitleView.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit
import SwiftUI

class StreamTitleView: UIView {
    
    private var liveStreamModel: LiveStreamModel?
    
    private let headPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "paopao")
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    private let streamTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)

        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 252/255, green: 157/255, blue: 154/255, alpha: 1)
        button.setTitle("Follow", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(headPhotoImageView)
        self.addSubview(usernameLabel)
        self.addSubview(streamTitle)
        self.addSubview(followButton)
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
    }
    
    @objc func followAction() {
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation"
       
        animation.fromValue = 0
        animation.toValue = Double.pi
        animation.autoreverses = true
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        followButton.layer.add(animation, forKey: nil)
//        followButton.isSelected = !followButton.isSelected
        
        DataPersistenceManager.shard.followTitleWith(model: self.liveStreamModel!) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Follow"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let space = 5.0
        let height = self.bounds.height - space * 2.0
        let width = self.bounds.width / 3
        headPhotoImageView.frame = CGRect(x: space, y: space, width: height, height: height)
        headPhotoImageView.layer.cornerRadius = headPhotoImageView.frame.height / 2
        headPhotoImageView.layer.masksToBounds = true
        
        usernameLabel.frame = CGRect(x: headPhotoImageView.frame.width + space * 2.0, y: 0, width: width, height: self.bounds.height / 2)
        
        streamTitle.frame = CGRect(x: usernameLabel.frame.origin.x, y: self.bounds.height / 2, width: usernameLabel.bounds.width, height: usernameLabel.bounds.height)
        
        followButton.frame = CGRect(x: usernameLabel.frame.origin.x + usernameLabel.bounds.width + space, y: space, width: usernameLabel.frame.width, height: headPhotoImageView.frame.height)
        
    }
    
    public func configure(liveStreamModel: LiveStreamModel?) {
        if liveStreamModel != nil {
            self.liveStreamModel = liveStreamModel!
            let user = liveStreamModel?.nickname ?? "無名稱"
            let title = liveStreamModel?.stream_title ?? "無標題"
            let photoUrl = liveStreamModel?.head_photo
            self.configure(photoUrlStr: photoUrl, user: user, title: title)
        }
    }
    
    private func configure(photoUrlStr: String?, user: String, title: String?) {
        if photoUrlStr != nil {
            let url = URL(string: photoUrlStr!)
            let data = try? Data(contentsOf: url!)
            if data != nil {
                let image = UIImage(data: data!)
                if image != nil {
                    DispatchQueue.main.async {
                        self.headPhotoImageView.image = image
                    }
                }
            }
            
        }
        self.usernameLabel.text = user
        if title != nil {
            self.streamTitle.text = title
        }
        
    }
}
