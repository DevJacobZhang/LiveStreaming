//
//  MyCollectionViewCell.swift
//  LiveStreaming
//
//  Created by Class on 2022/3/29.
//

import UIKit


protocol MyCollectionViewDelegate: AnyObject {
    func collectionViewTapCell(_ cell: MyCollectionView, Model:LiveStreamModel )
}


class MyCollectionViewCell: UICollectionViewCell {
    weak var delegate: MyCollectionViewDelegate?
    
    private var liveStreamModel: LiveStreamModel?
    
    static let identifier = "MyCollectionViewCell"
    
    private let width = Double(UIScreen.main.bounds.size.width)
    
    var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        return image
    }()
    
    var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var online_numLabel: OnlineNumberView = {
        let view = OnlineNumberView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.8
        return view
    }()
    
    var tagsLabel: TagsLabelView = {
        let label = TagsLabelView()
        return label
    }()
  
    let  gradientView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        contentView.layer.cornerRadius = 15.0
        contentView.layer.masksToBounds = true
        
        imageView.image = UIImage(named: "paopao") //預設image
        

//        self.addSubview(imageView)    //如果你打這行，是直接掛整個cell，而不是cell裡面的contentView！所以圓角功能等等都會失效。
        self.contentView.addSubview(imageView)  //所以要打這行，把要掛的東西確實掛到contentView裡面
        
        //實作透明到黑的漸層view讓直播主的名稱不會因為背景太白而看不見
        let offsetY = self.bounds.height / 1.5
        let gradientViewHeight = self.bounds.height - offsetY
        self.gradientView.frame = CGRect(x: 0, y: offsetY, width: self.bounds.width, height: gradientViewHeight)
        let layer = CAGradientLayer()
        layer.frame = self.gradientView.bounds
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor] // 由上到下，透明到黑
        gradientView.layer.addSublayer(layer)
        self.contentView.addSubview(gradientView)
        
        self.contentView.addSubview(nicknameLabel)
        
        self.contentView.addSubview(online_numLabel)
        
        self.contentView.addSubview(tagsLabel)
        
        
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: (width - 30)/2, height: (width - 30)/2)
        setMyContraints()
        online_numLabel.frame = CGRect(x: 10, y: 10, width: 80, height: 25)
        tagsLabel.frame = CGRect(x: 10, y: self.bounds.height / 1.5, width: self.bounds.width, height: 20)
    }
    
    func setMyContraints() {
        
        let nicknameLabelContraints = [
            nicknameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -self.bounds.width/2),
            nicknameLabel.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -self.bounds.height/1.2),
            nicknameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            nicknameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(nicknameLabelContraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(named: "paopao")
        self.nicknameLabel.text = nil
        self.online_numLabel.configure(number: 0)
        self.tagsLabel.configure(str: nil)
    }
    
    func configure(model: LiveStreamModel?) {

        guard model != nil else {
            print("cell configure faild: model is nil")
            return
        }
        
        
        /*-------------------------創建執行緒-----------------------------------------------*/
        //開一條執行緒去執行URL取得照片圖檔並解析，解析完後再回到主執行序去掛照片，不然整個App都在等！
        
        let myDataQueue = DispatchQueue(label: "DataQueue",
                                        qos: .userInitiated,
                                        attributes: .concurrent,
                                        autoreleaseFrequency: .workItem, target: nil)
        
        myDataQueue.async {
            let url = URL(string: model?.head_photo ?? "")
            guard let data = try? Data(contentsOf: url!) else {return}
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        /*----------------------------------------------------------------------------------*/

        self.nicknameLabel.text = model?.nickname
        self.online_numLabel.configure(number: model?.online_num ?? 0)
        self.tagsLabel.configure(str: model?.tags!)        
    }
        
}
