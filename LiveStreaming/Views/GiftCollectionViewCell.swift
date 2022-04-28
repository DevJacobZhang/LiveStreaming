//
//  GiftCollectionViewCell.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/27.
//

import UIKit

protocol GiftCollectionViewCellDelegate: NSObject {
    func didTapGiftWith(giftTag: Int)
}

class GiftCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GiftCollectionViewCell"
    
    weak var delegate: GiftCollectionViewCellDelegate?
    
    let giftButton: UIButton = {
        let button = UIButton()
        button.setTitle("Gift", for: .normal)
        button.backgroundColor = RandomColor().getRandomColor()
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
        
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        giftButton.addTarget(self, action: #selector(giftAction(_:)), for: .touchUpInside)
        self.contentView.addSubview(giftButton)
        
    }
    
    @objc private func giftAction(_ sender: UIButton) {
        self.delegate?.didTapGiftWith(giftTag: sender.tag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        giftButton.frame = self.bounds
    }
    
    public func configure(giftNumber: Int, giftName: String) {
        self.giftButton.setTitle(giftName, for: .normal)
        self.giftButton.tag = giftNumber
    }
}
