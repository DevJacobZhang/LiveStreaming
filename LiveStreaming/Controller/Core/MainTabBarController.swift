//
//  MainTabBarController.swift
//  LiveStreaming
//
//  Created by Class on 2022/4/17.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc1 = UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "ViewController"))!)
        let vc2 = UINavigationController(rootViewController: (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController"))!)
        let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "SelectorNavigationController")
        
        vc1.tabBarItem.title = NSLocalizedString("frontPage", comment: "")
        vc2.tabBarItem.title = NSLocalizedString("searchPage", comment: "")
        vc3?.tabBarItem.title = NSLocalizedString("personalPage", comment: "")
        
        vc1.tabBarItem.image = UIImage(named: "tabHome")
        vc2.tabBarItem.image = UIImage(named: "tabSearch")
        vc3?.tabBarItem.image = UIImage(named: "tabPersonal")
           
        self.setViewControllers([vc1,vc2,vc3!], animated: false)

    }
    
    //MARK: - 點擊tabBarItem動畫效果
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
        for (k,v) in (tabBar.items?.enumerated())! {
            if v == item {
                animationWithIndex(index: k)
            }
        }
    }
    
    func animationWithIndex(index: Int){
            var tabbarbuttonArray:[Any] = [Any]()
            
            for tabBarBtn in self.tabBar.subviews {
                if tabBarBtn.isKind(of: NSClassFromString("UITabBarButton")!) {
                    tabbarbuttonArray.append(tabBarBtn)
                }
            }
            
            let pulse = CABasicAnimation(keyPath: "transform.rotation")
            pulse.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            pulse.duration = 0.2
            pulse.repeatCount = 1
            pulse.autoreverses = true
            pulse.fromValue = 0
            pulse.toValue = (Double.pi * 2)
            
            let tabBarLayer = (tabbarbuttonArray[index] as AnyObject).layer
            tabBarLayer?.add(pulse, forKey: nil)

        }
}
