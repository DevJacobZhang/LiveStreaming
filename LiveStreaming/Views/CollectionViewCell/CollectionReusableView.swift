//
//  CollectionReusableView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/13.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    
    static let identifier = "HeaderCollectionReusableView"

    private let headPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "topPic")
        return imageView
    }()
    
     var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(headPhotoImageView)
        self.addSubview(nicknameLabel)
        self.headPhotoImageView.layer.cornerRadius = self.headPhotoImageView.bounds.width / 2
        self.headPhotoImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.headPhotoImageView.frame = CGRect(x: 10.0, y: 0, width: 30.0, height: 30.0)
        setConstraints()
        
    }
    
    func setConstraints() {
        let nicknameLabelConstraint = [
            self.nicknameLabel.topAnchor.constraint(equalTo: topAnchor),
            self.nicknameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            self.nicknameLabel.leadingAnchor.constraint(equalTo: self.headPhotoImageView.trailingAnchor, constant: 10),
            self.nicknameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(nicknameLabelConstraint)
    }
    
    func configure(withText: String) {
        self.nicknameLabel.text = withText
    }
    
    func configureSearchResult(withTitle: String) {
        self.nicknameLabel.translatesAutoresizingMaskIntoConstraints = true
        self.nicknameLabel.frame = CGRect(x: 10, y: 10, width: self.bounds.width, height: self.bounds.height - 20)
        self.nicknameLabel.text = withTitle
        self.nicknameLabel.font = .systemFont(ofSize: 25)
        self.headPhotoImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }    
    
}
