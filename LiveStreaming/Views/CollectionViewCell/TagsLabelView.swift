//
//  TagsLabelView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/3.
//

import UIKit

class TagsLabelView: UIView {

    var testAry: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(str: String?){
        
        if str == nil  { //檢查 若是nil代表清空上一個label來讓reuse使用，避免無限重疊
            for labb in testAry {
                labb.text = nil
                labb.frame.size = CGSize(width: 0, height: 0)
            }
            return
        } else if str == "" { //檢查 如果沒tags 則不要創建label了
            return
        }
        
        let tagsString = separateNewString(separateStr: str!)
        
        let fixedY = 0.0 //固定的Y
        let fixedSpace = 6.0 //固定的label與label中間的寬度
        var offsetX = 0.0 //連續記錄新的X軸
        let newWidth = 5.0 //讓label動態改變寬以外再加個3pt，避免剛好切邊
        
        for i in 0..<tagsString.count {
            let textString = tagsString[i]
            var mySize = CGSize()
            let textFont = UIFont.systemFont(ofSize: 17)
            let textMaxSize = CGSize(width: self.bounds.width, height: CGFloat(MAXFLOAT))
            
            let textLabelSize = textSize(text:textString , font: textFont, maxSize: textMaxSize)
            
            mySize.width = textLabelSize.width
            mySize.height = 20

            let label: UILabel = {
                let t = UILabel()
                t.backgroundColor = UIColor.black
                t.alpha = 0.7
                t.text = textString
                t.textColor = UIColor.white
                t.layer.cornerRadius = 10
                t.layer.masksToBounds = true
                t.textAlignment = .center
                t.font = UIFont.systemFont(ofSize: 17)
            
                t.frame = CGRect(x: offsetX, y: fixedY, width: mySize.width + newWidth, height: mySize.height)
                return t
            }()
            
            offsetX += (textLabelSize.width + newWidth + fixedSpace)//計算好下一個label的X軸出生點位子
            
            self.addSubview(label)
            self.testAry.append(label)
        }
    }
    
    func separateNewString(separateStr: String) -> [String] {
        
        var beforeStr: String = "#"
        var showStrAry:[String] = []
                
        let comma = ","
        
        for index in separateStr.indices {
            
            let word = String(separateStr[index])
            
            if word != comma {
                beforeStr += word //不是逗點就做相加
            } else {
                showStrAry.append(beforeStr)
                beforeStr = "#"
            }
            
        }
        showStrAry.append(beforeStr)//這是最後一組str或是只有一組str
        return showStrAry
    }
    
    //讓label的寬度因字串而動態調整
    func textSize(text : String , font : UIFont , maxSize : CGSize) -> CGSize{
        return text.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : font], context: nil).size
    }

    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
