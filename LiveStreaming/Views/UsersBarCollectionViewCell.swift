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
    
    let headButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.contentView.addSubview(myLabel)
//        self.contentView.addSubview(headButton)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myLabel.frame = self.bounds
        myLabel.layer.cornerRadius = myLabel.frame.width / 2
        myLabel.layer.masksToBounds = true
        
        headButton.frame = self.bounds
        headButton.layer.cornerRadius = headButton.frame.width / 2
        headButton.layer.masksToBounds = true
        headButton.layer.borderWidth = 1.5
        headButton.layer.borderColor = UIColor.lightGray.cgColor
        headButton.setImage(UIImage(named: "paopao"), for: .normal)

        
    }
    
    override func prepareForReuse() {
        self.myLabel.text = nil
        self.headButton.setImage(UIImage(named: "paopao"), for: .normal)
    }
    
    public func configure(text: String) {
        self.contentView.addSubview(self.myLabel)

        let index = text.startIndex
        let firstWord = String(text[index])
        self.myLabel.backgroundColor = RandomColor().getRandomColor()
        self.myLabel.text = firstWord
    }
    
    public func configureFollows(model: TitleItem) {
        self.contentView.addSubview(self.headButton)
        let url = URL(string: model.head_photo ?? "")
        let data = try? Data(contentsOf: url!)
        if data != nil {
            let image = UIImage(data: data!)
            if image != nil {
                DispatchQueue.main.async {
                    self.headButton.setImage(image, for: .normal)
                }
            }
        }
    }
}
