//
//  CustomAlertView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/12.
//


protocol CustomAlertViewDelegate: AnyObject {
    func userDidTapLeaveButton(leave:Bool)
}
import UIKit

class CustomAlertView: UIView {
    
    weak var delegate: CustomAlertViewDelegate?
    
    let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.3
        return view
    }()
    
    let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        return view
    }()
    
    let imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.backgroundColor = .clear
        imageV.image = UIImage(named: "brokenHeart")
        return imageV
    }()
    
    let label: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .black
        lb.text = "確定離開此聊天室？"
        return lb
    }()
    
    let leaveButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("立馬走", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    let stayButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("先不要", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //addsubview
        self.backgroundColor = UIColor.clear
        
        self.addSubview(backView)
        
        self.addSubview(alertView)
        
        self.alertView.addSubview(imageView)
        self.alertView.addSubview(label)
        self.alertView.addSubview(leaveButton)
        leaveButton.addTarget(self, action: #selector(leaveAction), for: .touchUpInside)
        
        self.alertView.addSubview(stayButton)
        stayButton.addTarget(self, action: #selector(stayAction), for: .touchUpInside)
        
    }
    
    @objc func leaveAction() {
        self.delegate?.userDidTapLeaveButton(leave: true)
        
    }
    
    @objc func stayAction() {
        self.delegate?.userDidTapLeaveButton(leave: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // frame
        self.backView.frame = self.bounds
        
        
        
        //----------------------------唯一調整alertView的框架大小及位置--------------------------------//
        
        self.alertView.frame.size = CGSize(width: self.bounds.width / 1.3, height: self.bounds.width / 1.7)
        self.alertView.center = self.backView.center
        
        //----------------------------------------------------------------------------------------//
        
        //以下都是依據alertView的框架來進行動態調整，唯有按鈕的四周Space是固定20px
        
        let offsetX = self.alertView.frame.width / 2.0
        let offsetY = self.alertView.frame.height / 7.0
        let imageWidth = self.alertView.frame.height / 2.5
        self.imageView.frame = CGRect(x: offsetX - (imageWidth / 2.0) , y: offsetY, width: imageWidth, height: imageWidth)
        
        let offsetYForLabel = self.imageView.frame.height + self.imageView.frame.origin.y
        self.label.frame = CGRect(x: 0, y: offsetYForLabel, width: self.alertView.frame.width, height: 20.0)
        
        var YforLeaveButton = (self.alertView.frame.height -  (self.label.frame.origin.y + self.label.frame.height)) / 2.0
        YforLeaveButton += (self.label.frame.origin.y + self.label.frame.height)
        let heightForLeaveButton = (self.alertView.frame.height -  (self.label.frame.origin.y + self.label.frame.height)) / 2.0
        let space = 20.0
        self.leaveButton.frame = CGRect(x: space, y: YforLeaveButton - space, width:(self.alertView.frame.width / 2.0) - space * 1.5 , height: heightForLeaveButton)
        
        let XforStayButton = self.leaveButton.frame.origin.x + self.leaveButton.frame.width
        self.stayButton.frame = CGRect(x: XforStayButton + space, y: YforLeaveButton - space, width: (self.alertView.frame.width / 2.0) - space * 1.5, height: heightForLeaveButton)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
