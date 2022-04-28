//
//  UsersBarCollectionViewCell.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/26.
//

import UIKit

class UsersBarCollectionViewCell: UICollectionViewCell {
    static let identifier = "UsersBarCollectionViewCell"
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.alpha = 1
        label.textAlignment = .center
        label.text = "T"
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(myLabel)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myLabel.frame = self.bounds
        myLabel.layer.cornerRadius = myLabel.frame.width / 2
        myLabel.layer.masksToBounds = true
        
    }
    override func prepareForReuse() {
        self.myLabel.text = nil
    }
    
    public func configure(text: String) {
        let index = text.startIndex
        let firstWord = String(text[index])
        self.myLabel.backgroundColor = RandomColor().getRandomColor()
        self.myLabel.text = firstWord
    }
}
