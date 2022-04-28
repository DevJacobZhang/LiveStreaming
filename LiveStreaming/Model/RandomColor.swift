//
//  randomColor.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/27.
//

import Foundation
import UIKit

class RandomColor {
    
    let colorOne = UIColor(red: 254/255, green: 67/255, blue: 101/255, alpha: 1)
    let colorTwo = UIColor(red: 252/255, green: 157/255, blue: 154/255, alpha: 1)
    let colorThree = UIColor(red: 249/255, green: 205/255, blue: 173/255, alpha: 1)
    let colorFour = UIColor(red: 200/255, green: 200/255, blue: 169/255, alpha: 1)
    let colorFive = UIColor(red: 131/255, green: 175/255, blue: 155/255, alpha: 1)
    
    func getRandomColor() -> UIColor {
        let random = Int.random(in: 1...5)
        switch random {
        case 1:
            return colorOne
        case 2:
            return colorTwo
        case 3:
            return colorThree
        case 4:
            return colorFour
        case 5:
            return colorFive
        default:
            return UIColor()
        }
    }
}
