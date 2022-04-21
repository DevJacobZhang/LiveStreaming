//
//  OnlineNumberView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/3.
//

import UIKit

class OnlineNumberView: UIView {

    private var myImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "iconPersonal")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    var onlineNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.black
        self.alpha = 0.8
        
        self.addSubview(myImageView)
        
        onlineNumLabel.text = "error"
        self.addSubview(onlineNumLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let offsetY = self.frame.height * 0.2

        let offsetWidth = self.frame.width/5
        let offsetHeight = self.frame.height - offsetY * 2
        myImageView.frame = CGRect(x: offsetWidth * 0.4, y: offsetY, width: offsetWidth, height: offsetHeight)
        onlineNumLabel.frame = CGRect(x: myImageView.frame.width + myImageView.frame.origin.x, y: offsetY, width: self.frame.width-(myImageView.frame.width + myImageView.frame.origin.x), height: offsetHeight)
    }
    
    func configure(number: Int) {
        let str = String(number)
        self.onlineNumLabel.text = str
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
