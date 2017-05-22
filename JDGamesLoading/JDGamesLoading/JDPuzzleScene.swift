//
//  JDPuzzleScene.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/5/18.
//  Copyright © 2017年 james12345. All rights reserved.
//

import UIKit
import SpriteKit

struct PuzzleBasicSetting {
    static let PuzzleCategoryName = "ball"
   
    static let BallCategory   : UInt32 = 0x1 << 0
    static let BlockCategory  : UInt32 = 0x1 << 1
    static let PaddleCategory : UInt32 = 0x1 << 2
    static let BorderCategory : UInt32 = 0x1 << 3
}

class JDPuzzleGamePuzzle:SKSpriteNode
{
    var MyIndex:CGPoint = CGPoint.zero
    static var Targettexture:SKTexture?
    
    
    init(size:CGSize,index:CGPoint) {
        let textrect:CGRect = CGRect(x: index.x * 1/3, y: index.y * 1/3, width: 1/3, height: 1/3)
        let texture:SKTexture = SKTexture(rect: textrect, in: JDPuzzleGamePuzzle.Targettexture!)
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.name = PuzzleBasicSetting.PuzzleCategoryName
        self.MyIndex = index
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(MyIndex.debugDescription)
        print(position.debugDescription)
    }
    
    static func makeAnArray(row:Int,size:CGSize)->[[JDPuzzleGamePuzzle?]]
    {
        let normalSize:CGSize = CGSize(width: size.width / CGFloat(row), height: size.height / CGFloat(row))
        let rows = row
        var Finalarray = [[JDPuzzleGamePuzzle?]]()
        
        for i in 0..<row
        {
            var oneArray = [JDPuzzleGamePuzzle?]()
            for j in 0..<rows
            {
                if(i == 1 && j == 1) //Middle Sapce
                {
                    oneArray.append(nil)
                }
                else
                {
                    let puzzle:JDPuzzleGamePuzzle = JDPuzzleGamePuzzle(size: normalSize, index: CGPoint(x: j, y: i))
                    oneArray.append(puzzle)

                }
            }
            Finalarray.append(oneArray)
        }
        return Finalarray
    }
}

class JDPuzzleScene: SKScene
{
    var row:Int = 3
    var PuzzleArray:[[JDPuzzleGamePuzzle?]]  = [[]] //Nil will be the empty hole
    var HoldedPuzzle:JDPuzzleGamePuzzle?
    var isMoving:Bool = false
    
    override init(size: CGSize) {
        super.init(size: size)
         self.backgroundColor = UIColor.clear
    }
    
    init(size: CGSize,configuration:JDBreaksGameConfiguration) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
       
        addImg()
        PuzzleArray = JDPuzzleGamePuzzle.makeAnArray(row: row,size: size)
        for array in PuzzleArray
        {
            for puzzle in array
            {
                guard let puzzle = puzzle else {
                    continue
                }
                let yindex = puzzle.MyIndex.y
                let xindex = puzzle.MyIndex.x
                let position = CGPoint(x: (puzzle.frame.width/2) * (2 * xindex + 1), y: (puzzle.frame.width/2) * (2 * yindex + 1))
                puzzle.position = position
                self.addChild(puzzle)
            }
        }
        randomStarted()
        //No gravity
        self.physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
      // borderBody.categoryBitMask = BreaksBasicSetting.BorderCategory
        //
    }
    
    func addImg()
    {
        var targetview:UIView = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let circlelayer:CAShapeLayer = CAShapeLayer()
        let circleFrame:CGRect = CGRect(x: 0.1 * frame.width, y: 0.1 * frame.height, width:  0.8 * frame.width, height:  0.8 * frame.height)
        let path:CGPath = CGPath(roundedRect: circleFrame, cornerWidth: size.width * 0.4, cornerHeight: size.width * 0.4, transform: nil)
        circlelayer.path = path
        circlelayer.frame = frame
        circlelayer.strokeColor = UIColor.red.cgColor
        circlelayer.fillColor = UIColor.clear.cgColor
        circlelayer.lineWidth = 5
        circlelayer.backgroundColor = UIColor.white.cgColor
        //
        targetview.layer.addSublayer(circlelayer)
        targetview.layer.backgroundColor = UIColor.clear.cgColor
        targetview.backgroundColor = UIColor.clear
        
        func ViewToImage()->UIImage?
        {
            UIGraphicsBeginImageContextWithOptions(targetview.bounds.size, false, 0)
            let sucess = targetview.drawHierarchy(in: targetview.bounds, afterScreenUpdates: true)
            if(sucess)
            {
                let image = UIGraphicsGetImageFromCurrentImageContext()
                return image
            }
            UIGraphicsEndImageContext()
            return nil
        }
        
        if let img = ViewToImage()
        {
            let texture = SKTexture(image: img)
            JDPuzzleGamePuzzle.Targettexture = texture
        }

    }
    
    func randomStarted()
    {
        var nilindex:CGPoint = CGPoint(x: 1, y: 1)
        func randomdirection()->CGVector
        {
            func randomInt() -> Int {
                let randomNum:UInt32 = arc4random_uniform(4)
                return Int(randomNum)
            }
            let vector = [CGVector(dx: 1, dy: 0),CGVector(dx: -1, dy: 0),CGVector(dx: 0, dy: 1),CGVector(dx: 0, dy: -1)]
            let rand = randomInt()
            return vector[rand]
        }
        //Start mash
        for _ in 0..<30
        {
            var vectornow = randomdirection()
            var targetindex = CGPoint.zero  //The choosen Puzzle index
            func canMove()->Bool
            {
                if(vectornow.dx != 0)
                {
                    let testingValue:CGFloat = nilindex.x + vectornow.dx
                    let bool1:Bool = ( Int(testingValue) < row) && (Int(testingValue) > -1)
                    if(bool1)
                    {
                        targetindex = CGPoint(x: testingValue, y: nilindex.y)
                        return true
                    }
                }
                if(vectornow.dy != 0)
                {
                    let testingValue:CGFloat = nilindex.y + vectornow.dy
                    let bool2:Bool = ( Int(testingValue) < row) && (Int(testingValue) > -1)
                    if(bool2)
                    {
                        targetindex = CGPoint(x: nilindex.x, y: testingValue)
                        return true
                    }
                }
                return false
            }
            while !canMove()
            {
                vectornow = randomdirection() //ReChoosen the target
            }
            if let puzzle = PuzzleArray[Int(targetindex.y)][Int(targetindex.x)] //Target
            {
                //Swipe index
                let temp1 = puzzle.MyIndex
                puzzle.MyIndex = nilindex
                nilindex = temp1
                //Swipe Array Index
                PuzzleArray[Int(puzzle.MyIndex.y)][Int(puzzle.MyIndex.x)] = puzzle
                PuzzleArray[Int(nilindex.y)][Int(nilindex.x)] = nil
                //
                puzzle.position.x = (puzzle.frame.width/2) * (2 * puzzle.MyIndex.x + 1)
                puzzle.position.y = (puzzle.frame.width/2) * (2 * puzzle.MyIndex.y + 1)
            }
        }
    }
    
    
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BreaksBasicSetting.BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1  //有磚塊存在就＋１
            
        }
        return numberOfBricks == 0
    }
    
}

extension JDPuzzleScene
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let puzzle = self.atPoint(touchLocation) as? JDPuzzleGamePuzzle
        {
             HoldedPuzzle = puzzle
             puzzle.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            if(isMoving)
            {
                return
            }
            // 1
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let preLocation = touch!.previousLocation(in: self)
            if let puzzle = HoldedPuzzle
            {
                var puzzleMoving:CGVector = CGVector.zero
                func moving()
                {
                    self.isMoving = true
                    let movingaction:SKAction = SKAction.move(by: puzzleMoving, duration: 0.4)
                    puzzle.run(movingaction, completion: {
                        self.isMoving = false
                    })
                    HoldedPuzzle = nil
                }
                let x:Int = Int(puzzle.MyIndex.x)
                let y:Int = Int(puzzle.MyIndex.y)
                if (touchLocation.x > preLocation.x) {
                    //finger touch went right
                    if( x < (row-1))
                    {
                        if(PuzzleArray[y][x+1] == nil)
                        {
                            PuzzleArray[y][x+1] = puzzle
                            PuzzleArray[y][x] = nil
                            puzzle.MyIndex = CGPoint(x: x+1, y: y)
                            puzzleMoving.dx = puzzle.frame.width
                            moving()
                        }
                    }
                    
                } else {
                    //finger touch went left
                    if( x > 0)
                    {
                        if(PuzzleArray[y][x-1] == nil)
                        {
                            PuzzleArray[y][x-1] = puzzle
                            PuzzleArray[y][x] = nil
                            puzzle.MyIndex = CGPoint(x: x-1, y: y)
                            puzzleMoving.dx = -puzzle.frame.width
                            moving()
                        }
                    }
                }
                if (touchLocation.y > preLocation.y) {
                    //finger touch went upwards
                    if( y < (row-1))
                    {
                        if(PuzzleArray[y+1][x] == nil)
                        {
                            PuzzleArray[y+1][x] = puzzle
                            PuzzleArray[y][x] = nil
                            puzzle.MyIndex = CGPoint(x: x, y: y+1)
                            puzzleMoving.dy = puzzle.frame.width
                            moving()
                        }
                    }
                } else {
                    //finger touch went downwards
                    if( y > 0)
                    {
                        if(PuzzleArray[y-1][x] == nil)
                        {
                            PuzzleArray[y-1][x] = puzzle
                            PuzzleArray[y][x] = nil
                            puzzle.MyIndex = CGPoint(x: x, y: y-1)
                            puzzleMoving.dy = -puzzle.frame.width
                            moving()
                        }
                    }
                }
                
                
            }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        HoldedPuzzle = nil
    }
    
}


extension JDPuzzleScene:SKPhysicsContactDelegate
{
    /*
     Delegate
     */
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 球碰到磚塊
        if firstBody.categoryBitMask == BreaksBasicSetting.BallCategory && secondBody.categoryBitMask == BreaksBasicSetting.BlockCategory {

        }
    }
    
}
