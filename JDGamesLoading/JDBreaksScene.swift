//
//  JDBreaksScene.swift
//  JDBreaksLoading
//
//  Created by 郭介騵 on 2016/12/14.
//  Copyright © 2016年 james12345. All rights reserved.
//

import SpriteKit
import GameplayKit

struct JDBreaksGameConfiguration {
    var paddle_color:UIColor = UIColor.white
    var ball_color:UIColor = UIColor.white
    var block_color:UIColor = UIColor.white
    var RowCount:Int = 1
    var ColumnCount:Int = 3
}

struct BreaksBasicSetting {
    static let BallCategoryName = "ball"
    static let PaddleCategoryName = "paddle"
    static let BlockCategoryName = "block"
    static let GameMessageName = "gameMessage"
    
    static let BallCategory   : UInt32 = 0x1 << 0
    static let BlockCategory  : UInt32 = 0x1 << 1
    static let PaddleCategory : UInt32 = 0x1 << 2
    static let BorderCategory : UInt32 = 0x1 << 3
}

class JDBreaksBrick:SKShapeNode
{
    init(size:CGSize,color:UIColor) {
        super.init()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(rect: rect, transform: nil)
        
        self.strokeColor = UIColor.black
        self.fillColor = color
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0.0
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.isDynamic = false
        self.name = BreaksBasicSetting.BlockCategoryName
        self.physicsBody!.categoryBitMask = BreaksBasicSetting.BlockCategory
        self.zPosition = 2
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JDBallNode:SKShapeNode
{
    init(size:CGSize,color:UIColor) {
        super.init()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(roundedRect: rect, cornerWidth: size.width * 0.5, cornerHeight: size.width * 0.5, transform: nil)
        //
        self.fillColor = color
        self.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.5)
        self.name = BreaksBasicSetting.BallCategoryName
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.frame.width * 0.5)
        self.physicsBody!.categoryBitMask = BreaksBasicSetting.BallCategory
        self.physicsBody!.isDynamic = true
        self.physicsBody!.friction = 0.0
        self.physicsBody!.restitution = 1.0
        self.physicsBody!.linearDamping = 0.0
        self.physicsBody!.angularDamping = 0.0
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.contactTestBitMask = BreaksBasicSetting.BlockCategory
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JDBreakPaddle:SKShapeNode
{
    init(size:CGSize,color:UIColor,radius:CGFloat) {
        super.init()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        self.path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
        //
        self.fillColor = color
        self.name = BreaksBasicSetting.PaddleCategoryName
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody!.categoryBitMask = BreaksBasicSetting.PaddleCategory
        self.physicsBody!.isDynamic = false
        self.physicsBody!.allowsRotation = true
        self.physicsBody!.angularDamping = 0.1
        self.physicsBody!.linearDamping = 0.1

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class JDBreaksScene: SKScene
{
    var isFingerOnPaddle = false
    var ball:JDBallNode!
    
    var gameWon : Bool = false {
        didSet {
            if(gameWon)
            {
                let holdQuene:DispatchQueue = DispatchQueue.global()
                let seconds = 0.5
                let delay = seconds * Double(NSEC_PER_SEC)
                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                holdQuene.asyncAfter(deadline: dispatchTime, execute: {
                    DispatchQueue.main.async(execute: { 
                        self.addBlock()
                    })
                })
            }
        }
    }
    
    var d_ballwidth:CGFloat = 20.0
    var ballwidth:CGFloat = 0.0
    var ballcolor:UIColor = UIColor.white
    
    var d_paddlewidth:CGFloat = 60
    var paddlewidth:CGFloat = 0.0
    var paddlecolor:UIColor = UIColor.white
    
    var defaultwindowwidth:CGFloat = 200.0
    var windowscale:CGFloat = 1.0
    
    var d_blockwidth:CGFloat = 40.0
    var blockwidth:CGFloat = 0.0
    var blockscolor:UIColor = UIColor.white
    
    var RowCount:Int = 2
    var ColumnCount:Int = 3
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    init(size: CGSize,configuration:JDBreaksGameConfiguration) {
        super.init(size: size)
        ballcolor = configuration.ball_color
        paddlecolor = configuration.paddle_color
        blockscolor = configuration.block_color
        RowCount = configuration.RowCount
        ColumnCount = configuration.ColumnCount
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        windowscale = (self.frame.width / defaultwindowwidth)
        ballwidth = d_ballwidth * windowscale
        paddlewidth = d_paddlewidth * windowscale
        blockwidth = d_blockwidth * windowscale
        
        self.backgroundColor = UIColor.clear
        
        //Set Border
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //Add Ball
        ball = JDBallNode(size: CGSize(width: ballwidth, height: ballwidth), color: ballcolor)
        self.addChild(ball)
        
        //No gravity
        self.physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        ball.physicsBody!.applyImpulse(CGVector(dx: 2.0, dy: -2.0))
        
        //Add Paddle
        let paddlesize:CGSize = CGSize(width: paddlewidth, height: 15)
        let paddle:JDBreakPaddle = JDBreakPaddle(size: paddlesize, color: paddlecolor, radius: 5)
        paddle.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.2)
        self.addChild(paddle)
        
        addBlock()

        borderBody.categoryBitMask = BreaksBasicSetting.BorderCategory
        //
    }
    
    func addBlock()
    {
        // 新增方塊
        let blockWidth:CGFloat = blockwidth
        let totalBlocksWidth = blockWidth * CGFloat(ColumnCount)
        // 2
        let xOffset = (frame.width - totalBlocksWidth) / 2
        //
        var FirstY:CGFloat = frame.height * 0.8
        for _ in 0..<RowCount
        {
            for col in 0..<ColumnCount
            {
                let size = CGSize(width: blockWidth, height: 15)
                let block = JDBreaksBrick(size: size, color: blockscolor)
                block.position = CGPoint(x: xOffset + CGFloat(CGFloat(col)) * blockWidth,
                                        y: FirstY)
                block.alpha = 0.0
                let fade:SKAction = SKAction.fadeAlpha(to: 1.0, duration: 2)
                block.run(fade)
                addChild(block)
            }
            FirstY -= 15
        }
    }
    
    func breakBlock(node: SKNode) {
        if( SKEmitterNode(fileNamed: "BrokenPlatform") != nil)
        {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                             SKAction.removeFromParent()]))
        }
        node.removeFromParent()
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

extension JDBreaksScene
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation)
        {
            if body.node!.name == BreaksBasicSetting.PaddleCategoryName {
                isFingerOnPaddle = true
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 是否壓著Bar
        if isFingerOnPaddle {
            // 2
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            // 3
            let paddle = childNode(withName: BreaksBasicSetting.PaddleCategoryName) as! SKShapeNode
            // Take the current position and add the difference between the new and the previous touch locations.
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            // Before repositioning the paddle, limit the position so that the paddle will not go off the screen to the left or right.
            paddleX = max(paddleX, paddle.frame.size.width/2)
            paddleX = min(paddleX, size.width - paddle.frame.size.width/2)
            // 6
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
}


extension JDBreaksScene:SKPhysicsContactDelegate
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
            breakBlock(node: secondBody.node!)
            gameWon = isGameWon()
        }
    }

}


