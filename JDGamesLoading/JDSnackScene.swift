//
//  JDSnackScene.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/2/14.
//  Copyright © 2017年 james12345. All rights reserved.
//

import SpriteKit
import GameplayKit

struct JDSnackGameConfiguration {
    var Snack_color:UIColor = UIColor.green
    var Food_color:UIColor = UIColor.white
    var Snack_Speed:CGFloat = 10.0
}

struct SnackBasicSetting {
    static let SnackHeadCategoryName = "SnackHead"
    static let SnackBodyCategoryName = "SnackBody"
    static let FoodCategoryName = "Food"
  
    static let SnackHeadCategory   : UInt32 = 0x1 << 0
    static let SnackBodyCategory : UInt32 = 0x1 << 1
    static let FoodCategory  : UInt32 = 0x1 << 2
    static var SnackPixelColor:UIColor = UIColor.green
}

struct TurnRoundPoint {
    var turnRoundPosition:CGPoint = CGPoint.zero
    var turnRoundDirection:CGVector = CGVector.zero
    var PassCounter:Int = 0
}

class SnackShapeNode:SKShapeNode
{
    var PixelSize:CGSize = CGSize.zero
    var InstanceDirection:CGVector = CGVector.zero
    init(size:CGSize) {
        super.init()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(rect: rect, transform: nil)
        PixelSize = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SnackHeadNode:SnackShapeNode
{
    
    override init(size:CGSize) {
        super.init(size:size)
        self.fillColor = SnackBasicSetting.SnackPixelColor
        self.name = SnackBasicSetting.SnackHeadCategoryName
        self.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
        self.physicsBody!.categoryBitMask = SnackBasicSetting.SnackHeadCategory
        self.physicsBody!.contactTestBitMask = SnackBasicSetting.FoodCategory
        self.physicsBody!.isDynamic = true
        self.physicsBody!.collisionBitMask = 0
        self.zPosition = 2
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SnackBodyNode:SnackShapeNode
{
    override init(size:CGSize) {
        super.init(size:size)
        self.position = CGPoint.zero
        self.fillColor = SnackBasicSetting.SnackPixelColor
        self.name = SnackBasicSetting.SnackBodyCategoryName
        self.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
        self.physicsBody!.categoryBitMask = SnackBasicSetting.SnackBodyCategory
        self.physicsBody!.isDynamic = false
        self.physicsBody!.collisionBitMask = 0
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class JDSnackScene: SKScene{
    
    var isFingerOnPaddle = false
    var gameWon : Bool = false {
        didSet {
            if(gameWon)
            {
                
            }
            
        }
    }
    /*
     Window Size
    */
    var defaultwindowwidth:CGFloat = 200.0
    var windowscale:CGFloat
        {
        get{
            return (self.frame.width / defaultwindowwidth)
        }
    }
    /*
     Pixel Size
     */
    var d_PixelSize:CGSize = CGSize(width: 15.0, height: 15.0)
    var PixelSize:CGSize
    {
        get{
            let size:CGSize = CGSize(width: d_PixelSize.width * windowscale, height:  d_PixelSize.width * windowscale)
            return size
        }
    }
    /*
     Pixel Color
    */
    var FoodPixelColor:UIColor = UIColor.white
    
    /*
     Snack
    */
    var SnackPixelArray:[SKShapeNode] = [SKShapeNode]()
    var SncakSpeed:CGFloat = 40
    var HeadPixel:SKShapeNode!
    /*
     Direction
    */
    var NowDirection:CGVector = CGVector(dx: 0.0, dy: 1.0)
    var LastTimeInterval:TimeInterval?
    var turnroundArr:[TurnRoundPoint] = [TurnRoundPoint]()
    
    
    
    override func update(_ currentTime: TimeInterval) {
        //Speed
        if(LastTimeInterval == nil) {LastTimeInterval = currentTime
            return}
        let InstanceScale:CGFloat =  CGFloat(currentTime - LastTimeInterval!)
        let InstanceSpeed:CGFloat = self.SncakSpeed * InstanceScale
        LastTimeInterval = currentTime
        let Vecter:CGVector = CGVector(dx: InstanceSpeed * NowDirection.dx, dy: InstanceSpeed * NowDirection.dy)
        //Update All Snack
        
        var LastPixelPoint:CGPoint?
        self.enumerateChildNodes(withName: SnackBasicSetting.SnackHeadCategoryName) {
            node, stop in
            if let snackHead:SnackHeadNode = node as? SnackHeadNode
            {
                LastPixelPoint = node.position
                let newPostition = CGPoint(x: (node.position.x) + (Vecter.dx), y: (node.position.y) + (Vecter.dy))
                snackHead.position = self.TouchTheWallDetect(input: newPostition)
            }
        }
        //
        var LastDirection:CGVector = NowDirection
        self.enumerateChildNodes(withName: SnackBasicSetting.SnackBodyCategoryName) {
            node, stop in
            if let NewPosition = LastPixelPoint,let snackBody:SnackBodyNode = node as? SnackBodyNode
            {
                if(snackBody.InstanceDirection == CGVector.zero) //NewPixel
                {
                   snackBody.position.x = NewPosition.x - LastDirection.dx * self.PixelSize.width
                   snackBody.position.y = NewPosition.y - LastDirection.dy * self.PixelSize.width
                   snackBody.InstanceDirection = LastDirection
                }
                else{
                    snackBody.position.x += snackBody.InstanceDirection.dx * InstanceSpeed
                    snackBody.position.y += snackBody.InstanceDirection.dy * InstanceSpeed
                    
                    for turnRound in self.turnroundArr
                    {
                        if( ( abs(snackBody.position.x - turnRound.turnRoundPosition.x) < 0.01 ) && abs(snackBody.position.y - turnRound.turnRoundPosition.y) < 0.01 )
                        {
                            snackBody.InstanceDirection = turnRound.turnRoundDirection
                        }
                    }
                }
                LastDirection = snackBody.InstanceDirection
                LastPixelPoint = snackBody.position
            }
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
    }
    
    init(size: CGSize,configuration:JDSnackGameConfiguration) {
        super.init(size: size)
        SnackBasicSetting.SnackPixelColor = configuration.Snack_color
        FoodPixelColor = configuration.Food_color
        SncakSpeed = configuration.Snack_Speed
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        //Set Border
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self
        //
        initSnack()
        AddrandomFood()
        //
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight(sender:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft(sender:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedUp(sender:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDown(sender:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    func initSnack()
    {
        HeadPixel = SnackHeadNode(size: PixelSize)
        HeadPixel.position = CGPoint(x: self.frame.width * 0.5 , y: self.frame.width * 0.5)
               self.addChild(HeadPixel)
        SnackPixelArray.append(HeadPixel)
    }
    
    func AddrandomFood()
    {
        let randomX:CGFloat = randomFloat(from: 0, to: self.frame.width)
        let randomY:CGFloat = randomFloat(from: 0, to: self.frame.height)
        let Food:SKShapeNode = SKShapeNode(rectOf: PixelSize)
        Food.position = CGPoint(x: randomX, y: randomY)
        Food.name = SnackBasicSetting.FoodCategoryName
        Food.fillColor = FoodPixelColor
        Food.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
        Food.physicsBody!.categoryBitMask = SnackBasicSetting.FoodCategory
        Food.physicsBody!.contactTestBitMask = SnackBasicSetting.SnackHeadCategory
        Food.physicsBody!.isDynamic = false
        Food.physicsBody!.collisionBitMask = 0
        Food.zPosition = 2
       
        self.addChild(Food)
    }
    
    func TouchTheWallDetect(input:CGPoint)->CGPoint
    {
        var result = input
        if(input.x > self.frame.width)
        {
            result.x = 0
        }
        else if(input.x < 0)
        {
            result.x = self.frame.width - 1
        }
        
        if(input.y > self.frame.height)
        {
            result.y = 0
        }
        else if(input.y < 0)
        {
            result.y = self.frame.height
        }
        return result
    }

    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    /*
     This method checks to see how many bricks are left in the scene by going through all the scene’s children. For each child, it checks whether the child name is equal to BlockCategoryName. If there are no bricks left, the player has won the game and the method returns true.
     */
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        
        return numberOfBricks == 0
    }
    
}

extension JDSnackScene
{
    func swipedRight(sender:UISwipeGestureRecognizer){
        self.NowDirection = CGVector(dx: 1.0, dy: 0.0)
        let NewTureRoundPoint:TurnRoundPoint = TurnRoundPoint.init(turnRoundPosition: HeadPixel.position, turnRoundDirection: NowDirection, PassCounter: 0)
        turnroundArr.append(NewTureRoundPoint)
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
         self.NowDirection = CGVector(dx: -1.0, dy: 0.0)
        let NewTureRoundPoint:TurnRoundPoint = TurnRoundPoint.init(turnRoundPosition: HeadPixel.position, turnRoundDirection: NowDirection, PassCounter: 0)
        turnroundArr.append(NewTureRoundPoint)
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        self.NowDirection = CGVector(dx: 0.0, dy: 1.0)
        let NewTureRoundPoint:TurnRoundPoint = TurnRoundPoint.init(turnRoundPosition: HeadPixel.position, turnRoundDirection: NowDirection, PassCounter: 0)
        turnroundArr.append(NewTureRoundPoint)
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
         self.NowDirection = CGVector(dx: 0.0, dy: -1.0)
         let NewTureRoundPoint:TurnRoundPoint = TurnRoundPoint.init(turnRoundPosition: HeadPixel.position, turnRoundDirection: NowDirection, PassCounter: 0)
         turnroundArr.append(NewTureRoundPoint)
    }
    
}


extension JDSnackScene:SKPhysicsContactDelegate
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
        
        if firstBody.categoryBitMask == SnackBasicSetting.SnackHeadCategory && secondBody.categoryBitMask == SnackBasicSetting.FoodCategory {
            if let food = secondBody.node
            {
                food.removeFromParent()
                AddrandomFood()
                let newHeadPixel = SnackBodyNode(size: PixelSize)
                self.addChild(newHeadPixel)
                SnackPixelArray.append(HeadPixel)
            }
            
        }

        
    }
    
    
    
}
