//
//  MinesweeperGameViewController.swift
//  LiveStreaming
//
//  Created by Cruise_Zhang on 2022/4/29.
//


import UIKit

class MinesweeperGameViewController: UIViewController {
    
    var bombAry = [[Int]]() //存放炸彈的位子
    var mineNum = 4 //地圖為4x4，因此使用4進制0~3，來將button的tag直接對應到座標
    var gameMap = [[Int]]() // 生成一個二維陣列代表地圖
    var totalNum = 0 //玩家總共可以按的次數，若4x4 2個炸彈 = 16 - 2 = 14的時候 代表玩家勝利
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalNum = mineNum * mineNum
        setGameMap()
        createMine(howmuch: 2)
        
    }
    
    func setGameMap() {
        
        for _ in 0 ..< mineNum {
            var ary = [Int]()
            for _ in 0 ..< mineNum {
                ary.append(1)
            }
            gameMap.append(ary)
        }
        print(gameMap)
    }

    
    func createMine(howmuch: Int) {
        for _ in 0 ..< howmuch {
            var ary = [Int]()
            let i = Int(arc4random_uniform(999))
            let j = Int(arc4random_uniform(500))
            ary.append(i % 4)
            ary.append(j % 4)
            bombAry.append(ary)
        }
        for i in 0 ..< howmuch {
            var changeAry = [Int]()
            changeAry = bombAry[i]
            gameMap[changeAry[0]][changeAry[1]] = 5
        }
        print(gameMap)
    }
    
    
    @IBAction func changeButton(_ sender: UIButton) {
        print("click the button's tag = \(sender.tag)")
        
        let clickTag = sender.tag
        var tagToAry = [Int]()
        //將按鈕的tag轉換成座標 十進制 轉 四進制 因為地圖4x4 所以是4進制座標
        tagToAry.append(clickTag / mineNum)
//        print("tagToAry[0] = \(clickTag / mineNum)")
        tagToAry.append(clickTag % mineNum)
//        print("tagToAry[1] = \(clickTag % mineNum)")
        
        let ans = gameMap[tagToAry[0]][tagToAry[1]]
        if ans == 5 {
            //按到地雷
            print("bingo!!!")
            self.stopAllButton()
//            sender.backgroundColor = UIColor.systemRed
            sender.setImage(UIImage(named: "mine"), for: .normal)
            
            let alertController = UIAlertController(title: "遊戲結束", message: "好笨哦", preferredStyle: .alert)
            let alert = UIAlertAction(title: "對，我好笨", style: .default, handler: { action in
                self.showBombGameOver()
                
            })
            alertController.addAction(alert)
            present(alertController, animated: true, completion: nil)
            
        }else{
            //沒按到地雷
            sender.setTitle(findBomb(buttonTag: sender.tag), for: .normal)
            if totalNum != 3 { //從16 一路扣到剩下2格的時候，此時totalNum == 3 代表玩家勝利
                totalNum -= 1
            } else { //totalNum == 3 就是最後一格按下去，遊戲結束的時候
                print("你贏了！！！")
                self.stopAllButton()
                let alertController = UIAlertController(title: "遊戲結束", message: "好強哦", preferredStyle: .alert)
                let alert = UIAlertAction(title: "送鑽石", style: .default, handler: { action in
                    self.showBombGameOver()
                    
                })
                alertController.addAction(alert)
                present(alertController, animated: true, completion: nil)
            }
            
            
        }
    }
    
    func stopAllButton() {
        for superStackView in self.view.subviews {
            if superStackView.isKind(of: UIStackView.self) {
                for stackView in superStackView.subviews {
                    if stackView.isKind(of: UIStackView.self) {
                        for buttonView in stackView.subviews {
                            if buttonView.isKind(of: UIButton.self){
                                let button = buttonView as! UIButton
                                if button.tag != 99 {
                                    button.isEnabled = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func restartGame() {
        gameMap.removeAll()
        bombAry.removeAll()
        setGameMap()
        createMine(howmuch: 2)
        resetViewAllObject()
        totalNum = mineNum * mineNum
        
    }
    
    @IBAction func restartButton(_ sender: AnyObject) {
        restartGame()
    }
    
    func resetViewAllObject() {
        for superStackView in self.view.subviews {
            if superStackView.isKind(of: UIStackView.self) {
                for stackView in superStackView.subviews {
                    if stackView.isKind(of: UIStackView.self) {
                        for buttonView in stackView.subviews {
                            if buttonView.isKind(of: UIButton.self){
                                let button = buttonView as! UIButton
                                if button.tag != 99 {
                                    button.setImage(nil, for: .normal)
                                    button.setTitle("", for: .normal)
                                    button.isEnabled = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func findBomb(buttonTag: Int) -> String {
        
        //x: Int, x1: Int, y: Int, y1: Int
        //偵測九宮格有幾顆炸彈並顯示在點擊位子
        
        return setCoordinate(buttonTag: buttonTag)
    
    }
    func setCoordinate(buttonTag: Int) -> String {
        
        //x = 起始位子 ， x1 = 結束位子
        //y = 起始位子 ， y1 = 結束位子
        var x:Int
        var x1:Int
        var y:Int
        var y1:Int
        
        let i = buttonTag / mineNum
        let j = buttonTag % mineNum
        //初始位子範圍，若沒遇到碰邊，範圍就是維持正常，搜尋九宮格有沒有炸彈
        x = i - 1
        x1 = i + 1
        y = j - 1
        y1 = j + 1
        
        //若點下去的格子是 靠上邊 靠左邊 靠右邊 靠下邊等等邊緣格子的話 因格子沒有-1的情況，陣列如果給[-1]會出錯，所以以下遇到邊緣格子時，修改陣列的取值範圍！
        if i == 0 || i == 3{ //i代表座標x，也就是遇到上邊時不能往上，遇到下邊時不能往下取值
            if i == 0 {
                // i = 0 代表點到的是上邊，不能再往上取值
                x = i
                x1 = i + 1
            } else {
                // i = 3 代表點到的是下邊，不能再往下取值
                x = i - 1
                x1 = i
            }
        }
        if j == 0 || j == 3 { //j代表座標y，也就是遇到左邊時不能往左，遇到右邊時不能往右取值
            if j == 0 {
                // j = 0 代表點到的是左邊，不能再往左取值
                y = j
                y1 = j + 1
            } else {
                // j = 3 代表點到的是右邊，不能再往右取值
                y = j - 1
                y1 = j
            }
        }
        
        var aroundBumbs = 0 //用來記錄九宮格內有幾個炸彈，並拿來顯示在畫面上
        
        for x in x ... x1 {
            for y in y ... y1 {
                if gameMap[x][y] == 5 {
                    aroundBumbs += 1
                }
            }
        }
        return String(aroundBumbs) //回傳出去，用來顯示在畫面上
    }
    
    
    func showBombGameOver() { //遊戲結束，無論贏還是失敗，按下alert之後都將炸彈顯示出來
        
        var tagAry = [Int]() //用來儲存將座標轉換回十進制tag值，即可針對tag值的button進行顯示照片
        
        //座標 轉換成 十進制tag 就是 四進制 轉 十進制
        for i in 0 ..< bombAry.count {
            let ary = bombAry[i]
            let a = Int(Double(ary[0]) * pow(4.0, 1.0)) //例如座標(1,3) 這一行代表 1 * 4的1次方 = 1 * 4
            let b = Int(Double(ary[1]) * pow(4.0, 0.0)) //例如座標(1,3) 這一行代表 3 * 4的0次方 = 3 * 1
            let c = a + b
//            print("炸彈位子 tag = \(c)")
            tagAry.append(c)
        }
        
        
        for subview in self.view.subviews {
            if subview.isKind(of: UIButton.self) && subview.tag < 50 {
                let tag = subview.tag
                if tagAry.contains(tag) {
                    print("抓到了 \(tag) 是炸彈！")
                    let button = subview as! UIButton
                    button.setImage(UIImage(named: "mine"), for: .normal)
                }
                
                
            }
        }
    }
    
    
    
}

    


    
