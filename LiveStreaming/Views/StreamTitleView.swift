//
//  StreamTitleView.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit
import SwiftUI

class StreamTitleView: UIView {
    
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
        button.backgroundColor = .blue
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
    
    public func configure(photoUrlStr: String?, user: String, title: String?) {
        if photoUrlStr != nil {
            let url = URL(string: photoUrlStr!)
            guard let data = try? Data(contentsOf: url!) else {return}
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.headPhotoImageView.image = image
            }
        }
        self.usernameLabel.text = user
        if title != nil {
            self.streamTitle.text = title
        }
        
    }
}
