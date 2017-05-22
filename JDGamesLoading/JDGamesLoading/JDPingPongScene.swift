//
//  JDPingPongScene.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/3/6.
//  Copyright © 2017年 james12345. All rights reserved.
//

import SpriteKit
import GameplayKit



class JDPingPongScene: SKScene
{
    var isFingerOnPaddle = false
    var ball:JDBallNode!
    
    var gameWon : Bool = false {
        didSet {
            if(gameWon)
            {
               
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

    override init(size: CGSize) {
        super.init(size: size)
    }
    
    init(size: CGSize,configuration:JDPingPongConfiguration) {
        super.init(size: size)
        ballcolor = configuration.ball_color
        paddlecolor = configuration.paddle_color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.enumerateChildNodes(withName: BreaksBasicSetting.PaddleCategoryName, using: { (node, point) in
            if let paddle:JDBreakPaddle = node as? JDBreakPaddle
            {
                if(paddle.side == .Enemy)
                {
                    paddle.position = CGPoint(x: self.ball.position.x, y: paddle.position.y)
                }
            }
        })
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        windowscale = (self.frame.width / defaultwindowwidth)
        ballwidth = d_ballwidth * windowscale
        paddlewidth = d_paddlewidth * windowscale

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
        paddle.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.1)
        paddle.side = .Own
        self.addChild(paddle)
    
        let paddle2:JDBreakPaddle = JDBreakPaddle(size: paddlesize, color: paddlecolor, radius: 5)
        paddle2.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.width * 0.8)
        paddle2.side = .Enemy
        self.addChild(paddle2)
        
        //
        borderBody.categoryBitMask = BreaksBasicSetting.BorderCategory
        //
    }
   
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
}

extension JDPingPongScene
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        let node = self.atPoint(touchLocation)
        if let paddle:JDBreakPaddle = node as? JDBreakPaddle
        {
            if(paddle.side == .Own)
            {
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
            self.enumerateChildNodes(withName: BreaksBasicSetting.PaddleCategoryName, using: { (node, point) in
                if let paddle:JDBreakPaddle = node as? JDBreakPaddle
                {
                    if(paddle.side == .Own)
                    {
                        var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
                        paddleX = max(paddleX, paddle.frame.size.width/2)
                        paddleX = min(paddleX, self.size.width - paddle.frame.size.width/2)
                        // 6
                        paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
                    }
                }
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
}


extension JDPingPongScene:SKPhysicsContactDelegate
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



