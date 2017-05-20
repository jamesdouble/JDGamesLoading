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

class JDPuzzleGamePuzzle:SKShapeNode
{
    var MyIndex:CGPoint = CGPoint.zero
    static var Targettexture:SKTexture?
    init(size:CGSize,index:CGPoint) {
        super.init()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(rect: rect, transform: nil)
        self.name = PuzzleBasicSetting.PuzzleCategoryName
        self.fillColor = UIColor.red
        self.MyIndex = index
        self.fillTexture = getTextureRect()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTextureRect()->SKTexture
    {
        let rect:CGRect = CGRect(x: MyIndex.x, y: MyIndex.y, width: 1/3, height: 1/3)
        return SKTexture(rect: rect, in: JDPuzzleGamePuzzle.Targettexture!)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(MyIndex.debugDescription)
        print(position.debugDescription)
    }
    
    static func makeAnArray(row:Int,size:CGSize)->[[JDPuzzleGamePuzzle]]
    {
        let normalSize:CGSize = CGSize(width: size.width / CGFloat(row), height: size.height / CGFloat(row))
        let rows = row
        var Finalarray = [[JDPuzzleGamePuzzle]]()
        
        for i in 0..<row
        {
            var oneArray = [JDPuzzleGamePuzzle]()
            for j in 0..<rows
            {
                let puzzle:JDPuzzleGamePuzzle = JDPuzzleGamePuzzle(size: normalSize, index: CGPoint(x: j, y: i))
                oneArray.append(puzzle)
            }
            Finalarray.append(oneArray)
        }
        return Finalarray
    }
}

class JDPuzzleScene: SKScene
{
    var row:Int = 3
    var PuzzleArray:[[JDPuzzleGamePuzzle]]  = [[]]
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
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
       
        /*
        for array in PuzzleArray
        {
            for puzzle in array
            {
                let yindex = puzzle.MyIndex.y
                let xindex = puzzle.MyIndex.x
                let position = CGPoint(x: (puzzle.frame.width/2) * (2 * xindex ), y: (puzzle.frame.width/2) * (2 * yindex))
                puzzle.position = position
                self.addChild(puzzle)
            }
        }
        */
        //Set Border
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //No gravity
        self.physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        borderBody.categoryBitMask = BreaksBasicSetting.BorderCategory
        //
        ///addImg()
    }
    
    func addImg()
    {
        var targetview:UIView = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let circlelayer:CAShapeLayer = CAShapeLayer()
        let path:CGPath = CGPath(roundedRect: frame, cornerWidth: size.width/2, cornerHeight: size.width/2, transform: nil)
        circlelayer.path = path
        circlelayer.frame = frame
        circlelayer.strokeColor = UIColor.lightGray.cgColor
        circlelayer.fillColor = UIColor.clear.cgColor
        circlelayer.lineWidth = 5
        circlelayer.cornerRadius = size.width/2
        circlelayer.backgroundColor = UIColor.clear.cgColor
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
            
            let node:SKSpriteNode = SKSpriteNode(texture: JDPuzzleGamePuzzle.Targettexture!)
            node.size = CGSize(width: size.width / 3, height: size.width / 3)
            node.position = CGPoint(x: size.width / 2, y: size.height / 2 )
            self.addChild(node)
            //JDPuzzleGamePuzzle.Targettexture = SKTexture(image: img)
            //PuzzleArray = JDPuzzleGamePuzzle.makeAnArray(row: row,size: size)
        }

    }
    
    
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
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
             puzzle.touchesBegan(touches, with: event)
        }
    
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            // 2
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       
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
