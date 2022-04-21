//
//  ChatLabelView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/13.
//

import UIKit

class ChatLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var chatLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        chatLable.layer.cornerRadius = 10
        chatLable.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(msgText: String?) {
        if msgText != nil {
            self.chatLable.text = msgText!
        }
    }
}
