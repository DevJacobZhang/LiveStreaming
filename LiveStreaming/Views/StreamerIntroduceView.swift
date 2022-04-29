//
//  StreamerIntroduceView.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/29.
//

import Foundation
import UIKit

protocol StreamerIntroduceViewDelegate: NSObject {
    func didTapDoneButton()
}

class StreamerIntroduceView: UIView {
    
    weak var delegate: StreamerIntroduceViewDelegate?
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
//        view.alpha = 0.5
        
        return view
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let photoImg: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "paopao")
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.text = "凌晨"
        return label
    }()
    
    private let streamTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.alpha = 0.8
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "今天感冒不想講話"
        return label
    }()
    
    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "带投,嫩模"
        return label
    }()
    
    private let streamerIDLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "88952"
        return label
    }()
    
    private let streamerIdL: UILabel = {
        let label = UILabel()
        label.text = "Streamer id:"
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.alpha = 0.8

        return label
    }()
    
    private let tagsL: UILabel = {
        let label = UILabel()
        label.text = "Tags:"
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.alpha = 0.8

        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.alpha = 0.3
        return view
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backView)
        self.addSubview(infoView)
        self.addSubview(photoImg)
        infoView.addSubview(usernameLabel)
        infoView.addSubview(streamTitle)
        infoView.addSubview(streamerIdL)
        infoView.addSubview(tagsL)
        infoView.addSubview(streamerIDLabel)
        infoView.addSubview(tagsLabel)
        infoView.addSubview(lineView)
        infoView.addSubview(followButton)
        self.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
    }
    
    @objc private func doneAction() {
        self.delegate?.didTapDoneButton()
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0) {
//            self.photoImg.frame.origin.y += self.frame.height
//            self.infoView.frame.origin.y += self.frame.height
//            self.doneButton.frame.origin.y += self.frame.height + self.doneButton.frame.height
//            self.backView.alpha = 0
//        }
    }
    
    private func initViewFrame() {
        self.photoImg.frame.origin.y += self.frame.height
        self.infoView.frame.origin.y += self.frame.height
        self.doneButton.frame.origin.y += self.frame.height + self.doneButton.frame.height
        self.backView.alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backView.frame = self.bounds
        let width = self.frame.width / 2.5
        photoImg.frame.size = CGSize(width: width, height: width)
        photoImg.center = backView.center
        let space = 25.0
        infoView.frame = CGRect(x: space, y: self.frame.height/2.0, width: self.frame.width - space * 2.0, height: self.frame.height / 2.7)
        usernameLabel.frame.size = CGSize(width: infoView.frame.width, height: infoView.frame.height / 7)
        let infoViewCenterX = infoView.frame.width / 2
        let infoViewCenterY = infoView.frame.height * 0.45
        usernameLabel.center = CGPoint(x: infoViewCenterX, y: infoViewCenterY)
        
        streamTitle.frame = CGRect(x: 0, y: infoView.frame.height * 0.25, width: infoView.frame.width, height: usernameLabel.frame.height)
        streamerIdL.frame = CGRect(x: space / 2, y: infoView.frame.height * 0.5, width: 100, height: 40)
        tagsL.frame = CGRect(x: space / 2, y: infoView.frame.height * 0.65, width: 50, height: 40)
        
        //在streamerIdL右邊
        let rightSideWithIdL = streamerIdL.frame.origin.x + streamerIdL.frame.width
        streamerIDLabel.frame = CGRect(x: rightSideWithIdL, y: infoView.frame.height * 0.5, width: 100, height: 40)
        let rightSideWithTagsL = tagsL.frame.origin.x + tagsL.frame.width
        tagsLabel.frame = CGRect(x: rightSideWithTagsL, y: infoView.frame.height * 0.65, width: infoView.frame.width, height: 40)
        
        lineView.frame = CGRect(x: 0, y: infoView.frame.height * 0.83, width: infoView.frame.width, height: 1.0)
        
        
        followButton.frame = CGRect(x: 0, y: infoView.frame.height * 0.83, width: infoView.frame.width, height: infoView.frame.height - lineView.frame.origin.y)
        
        let doneButtonY = infoView.frame.origin.y + infoView.frame.height + 20.0
        doneButton.frame = CGRect(x: infoView.frame.origin.x, y: doneButtonY, width: infoView.frame.width, height: 60)
    }
    public func configure(headphoto: UIImage?, liveStreamModel: LiveStreamModel?) {
        if liveStreamModel?.head_photo != nil {
            let url = URL(string: liveStreamModel?.head_photo! ?? "")
            let data = try? Data(contentsOf: url!)
            if data != nil {
                let image = UIImage(data: data!)
                if image != nil {
                    DispatchQueue.main.async {
                        self.photoImg.image = image
                    }
                }
            }
        }
        self.streamTitle.text = liveStreamModel?.stream_title
        self.tagsLabel.text = liveStreamModel?.tags
        self.usernameLabel.text = liveStreamModel?.nickname
        self.streamerIDLabel.text = "\(liveStreamModel?.streamer_id ?? 0)"
    }
}
