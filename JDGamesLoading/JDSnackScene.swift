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



class JDSnackScene: SKScene{
    
    let SnackHeadCategoryName = "SnackHead"
    let SnackBodyCategoryName = "SnackBody"
    let FoodCategoryName = "Food"
    
    let SnackHeadCategory   : UInt32 = 0x1 << 0
    let SnackBodyCategory : UInt32 = 0x1 << 1
    let FoodCategory  : UInt32 = 0x1 << 2
    
    var isFingerOnPaddle = false
    var ball:SKShapeNode!
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
    var SnackPixelColor:UIColor = UIColor.green
    var FoodPixelColor:UIColor = UIColor.white
    
    /*
     Snack
    */
    var SnackPixelArray:[SKShapeNode] = [SKShapeNode]()
    var SncakSpeed:CGFloat = 100
    var HeadPixel:SKShapeNode!
    /*
     Direction
    */
    var NowDirection:CGVector = CGVector(dx: 0.0, dy: 1.0)
    var LastTimeInterval:TimeInterval?
    
    override func update(_ currentTime: TimeInterval) {
        //RecOld
        var OldPosition:[CGPoint] = [CGPoint]()
        for pixel in SnackPixelArray
        {
            OldPosition.append(pixel.position)
        }
        //Speed
        if(LastTimeInterval == nil) {LastTimeInterval = currentTime
            return}
        let InstanceSpeed:CGFloat = self.SncakSpeed * CGFloat(currentTime - LastTimeInterval!)
        LastTimeInterval = currentTime
        let Vecter:CGVector = CGVector(dx: InstanceSpeed * NowDirection.dx, dy: InstanceSpeed * NowDirection.dy)
        //Update All Snack
        var LastPixelPosition:CGPoint?
        for pixel in SnackPixelArray
        {
            if let lastPostion = LastPixelPosition
            {
                pixel.position = lastPostion
            }
            else //FirstPixel
            {
                LastPixelPosition = pixel.position
                let newPostition = CGPoint(x: (LastPixelPosition?.x)! + (Vecter.dx), y: (LastPixelPosition?.y)! + (Vecter.dy))
                pixel.position = TouchTheWallDetect(input: newPostition)
            }
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
    }
    
    init(size: CGSize,configuration:JDSnackGameConfiguration) {
        super.init(size: size)
        SnackPixelColor = configuration.Snack_color
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
        HeadPixel = SKShapeNode(rectOf: PixelSize)
        HeadPixel.position = CGPoint(x: self.frame.width * 0.5 , y: self.frame.width * 0.5)
        HeadPixel.fillColor = SnackPixelColor
        HeadPixel.name = SnackHeadCategoryName
        HeadPixel.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
        HeadPixel.physicsBody!.categoryBitMask = SnackHeadCategory
        HeadPixel.physicsBody!.contactTestBitMask = FoodCategory
        HeadPixel.physicsBody!.isDynamic = true
        HeadPixel.physicsBody!.collisionBitMask = 0
       
        HeadPixel.zPosition = 2
        self.addChild(HeadPixel)
        SnackPixelArray.append(HeadPixel)
    }
    
    func AddrandomFood()
    {
        let randomX:CGFloat = randomFloat(from: 0, to: self.frame.width)
        let randomY:CGFloat = randomFloat(from: 0, to: self.frame.height)
        let Food:SKShapeNode = SKShapeNode(rectOf: PixelSize)
        Food.position = CGPoint(x: randomX, y: randomY)
        Food.name = FoodCategoryName
        Food.fillColor = FoodPixelColor
        Food.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
        Food.physicsBody!.categoryBitMask = FoodCategory
        Food.physicsBody!.contactTestBitMask = SnackHeadCategory
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
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
         self.NowDirection = CGVector(dx: -1.0, dy: 0.0)
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        self.NowDirection = CGVector(dx: 0.0, dy: 1.0)
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
         self.NowDirection = CGVector(dx: 0.0, dy: -1.0)
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
        
        if firstBody.categoryBitMask == SnackHeadCategory && secondBody.categoryBitMask == FoodCategory {
            if let food = secondBody.node
            {
                food.removeFromParent()
                AddrandomFood()
                let newHeadPixel = SKShapeNode(rectOf: PixelSize)
                newHeadPixel.position = CGPoint.zero
                newHeadPixel.fillColor = SnackPixelColor
                newHeadPixel.name = SnackBodyCategoryName
                newHeadPixel.physicsBody = SKPhysicsBody(rectangleOf: PixelSize)
                newHeadPixel.physicsBody!.categoryBitMask = SnackBodyCategory
                newHeadPixel.physicsBody!.isDynamic = false
                newHeadPixel.physicsBody!.collisionBitMask = 0
                newHeadPixel.zPosition = 2
                self.addChild(newHeadPixel)
                SnackPixelArray.append(HeadPixel)
            }
            
        }

        
    }
    
    
    
}
