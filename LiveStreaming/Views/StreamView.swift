//
//  StreamView.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/11.
//

import UIKit
import AVFoundation

class StreamView: UIView {

    var player: AVPlayer?
    
    var layeee: AVPlayerLayer? = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        let path = Bundle.main.path(forResource: "hime3", ofType: "mp4")
        let remoteURL = URL(fileURLWithPath: path!)
        
        self.player = AVPlayer(url: remoteURL)
        layeee?.player = self.player
        layeee?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        layeee?.frame = CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        guard layeee != nil else { return }
        self.layer.addSublayer(layeee!)
        
//        player?.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func playRemove() {
        self.layeee?.removeFromSuperlayer()
        self.player?.pause()
        self.layeee = nil
        self.player = nil
        
    }
}
