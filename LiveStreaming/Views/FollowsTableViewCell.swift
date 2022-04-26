//
//  FollowsTableViewCell.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit
import SwiftUI

class FollowsTableViewCell: UITableViewCell {
    
    static let identifier = "FollowsTableViewCell"
    
    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        let color = UIColor(red: 252/255, green: 157/255, blue: 154/255, alpha: 1)
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    private let headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "paopao")
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(backView)
        self.contentView.addSubview(nicknameLabel)
        self.contentView.addSubview(headImageView)
        self.contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        constraints()
        let space = 10.0
        let offsetHeight = self.bounds.height - space * 2.0
        headImageView.frame = CGRect(x: space, y: space, width: offsetHeight , height: offsetHeight)
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
        headImageView.layer.masksToBounds = true
        
        let width = self.bounds.width / 2
        nicknameLabel.frame = CGRect(x: headImageView.frame.width + space * 2.0, y: 0, width: width, height: self.bounds.height / 2)
        titleLabel.frame = CGRect(x: nicknameLabel.frame.origin.x, y: self.bounds.height / 2, width: nicknameLabel.bounds.width, height: nicknameLabel.bounds.height)
        
        
    }
    
    private func constraints() {
        let backViewContraint = [
            backView.topAnchor.constraint(equalTo: self.topAnchor, constant: +5),
            backView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: +5),
            backView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:  -5),
            backView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -10)
        ]
        NSLayoutConstraint.activate(backViewContraint)
    }
    
    public func configure(model: TitleItem) {
        let url = URL(string: model.head_photo ?? "")
        let data = try? Data(contentsOf: url!)
        if data != nil {
            let image = UIImage(data: data!)
            if image != nil {
                DispatchQueue.main.async {
                    self.headImageView.image = image
                }
            }
        }
        self.nicknameLabel.text = model.nickname
        self.titleLabel.text = model.stream_title
    }
    
    override func prepareForReuse() {
        nicknameLabel.text = nil
        titleLabel.text = nil
        headImageView.image = UIImage(named: "paopao")
    }
}
