//
//  JDGamesLoading.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/2/13.
//  Copyright © 2017年 james12345. All rights reserved.
//

import UIKit
import SpriteKit

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

public enum GamePack
{
    case Breaks
    case Snacks
    case PingPong
    case Puzzle
}


public class JDGamesLoading:NSObject
{
    static var PrsentedViewController:JDLoadingViewController?
    var ChoosingGame:GamePack?
    public init(game:GamePack)
    {
        ChoosingGame = game
        JDGamesLoading.PrsentedViewController = JDLoadingViewController(gamesType: game)
        JDGamesLoading.PrsentedViewController?.modalPresentationStyle = .overCurrentContext
        JDGamesLoading.PrsentedViewController?.modalTransitionStyle = .coverVertical
    }
    
    public func withConfiguration(configuration:JDGamesConfiguration)->JDGamesLoading
    {
        if let choosinggames = ChoosingGame
        {
            if let snackConfig = configuration as? JDSnackGameConfiguration,choosinggames == .Snacks
            {
                JDGamesLoading.PrsentedViewController = JDLoadingViewController(gamesType: choosinggames, config: snackConfig)
            }
            if let breakConfig = configuration as? JDBreaksGameConfiguration,choosinggames == .Snacks
            {
                JDGamesLoading.PrsentedViewController = JDLoadingViewController(gamesType: choosinggames, config: breakConfig)
                
            }
            if let pingConfig = configuration as? JDPingPongConfiguration,choosinggames == .PingPong
            {
                JDGamesLoading.PrsentedViewController = JDLoadingViewController(gamesType: choosinggames, config: pingConfig)
            }
            JDGamesLoading.PrsentedViewController?.modalPresentationStyle = .overCurrentContext
            JDGamesLoading.PrsentedViewController?.modalTransitionStyle = .coverVertical
        }
        return self
    }
    
    public func show()
    {
        if let VC = UIApplication.topViewController(),let JDVC = JDGamesLoading.PrsentedViewController
        {
            VC.present(JDVC, animated: true, completion: nil)
        }
    }
    
    public func demoPresent()
    {
        if let JDVC = JDGamesLoading.PrsentedViewController
        {
            let NAV = UINavigationController(rootViewController:  JDVC)
            NAV.modalPresentationStyle = .overCurrentContext
            NAV.modalTransitionStyle = .coverVertical
            
            //
            let barButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(self.dismiss))
            JDVC.navigationItem.leftBarButtonItem = barButton
            //
            
            if let VC = UIApplication.topViewController() {
                VC.present(NAV, animated: true, completion: nil)
            }
        }
    }
    
    static func dismiss()
    {
        if let VC = UIApplication.topViewController() {
                VC.dismiss(animated: true, completion: nil)
        }
        JDGamesLoading.PrsentedViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func dismiss()
    {
        if let VC = UIApplication.topViewController() {
            VC.dismiss(animated: true, completion: nil)
        }
        JDGamesLoading.PrsentedViewController?.dismiss(animated: true, completion: nil)
    }
}

class JDLoadingViewController:UIViewController
{
     var indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
     var ContainerView:UIView = UIView()
     var skview:SKView!
     var skscene:SKScene!
     var GameType:GamePack = .Breaks
     var frame:CGRect!
     var gameconfig:JDGamesConfiguration?
    
    init(gamesType:GamePack) {
        super.init(nibName: nil, bundle: nil)
        GameType = gamesType
    }
    
    init(gamesType:GamePack,config:JDGamesConfiguration) {
        super.init(nibName: nil, bundle: nil)
        GameType = gamesType
        gameconfig = config
    }
    
   

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        //
        frame = CGRect(x: self.view.frame.width * 1/4 , y: self.view.frame.height * 1/2 - self.view.frame.width * 1/4 , width: self.view.frame.width * 1/2 , height: self.view.frame.width * 1/2)
        //
        initView()
        
        let skviewframe:CGRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        if(GameType == .Breaks)
        {
            if let breakconfig = gameconfig as? JDBreaksGameConfiguration
            {
                skscene = JDBreaksScene(size: skviewframe.size, configuration: breakconfig)
            }
            else
            {
                skscene = JDBreaksScene(size: skviewframe.size)
            }
        }
        else if(GameType == .Snacks)
        {
            if let sncakconfig = gameconfig as? JDSnackGameConfiguration
            {
                skscene = JDSnackScene(size: skviewframe.size, configuration: sncakconfig)
            }
            else
            {
                skscene = JDSnackScene(size: skviewframe.size)
            }
        }
        else if(GameType == .PingPong)
        {
            if let pingconfig = gameconfig as? JDPingPongConfiguration
            {
                skscene = JDPingPongScene(size: skviewframe.size, configuration: pingconfig)
            }
            else
            {
                skscene = JDPingPongScene(size: skviewframe.size)
            }
        }
        else if(GameType == .Puzzle)
        {
            skscene = JDPuzzleScene(size: skviewframe.size)
        }
        skview.presentScene(skscene)
    }
    
    func initView()
    {
        ContainerView.frame = frame
        ContainerView.backgroundColor = UIColor.clear
        ContainerView.layer.cornerRadius = 0.25 * frame.width
        self.view.addSubview(ContainerView)
        
        let skviewframe:CGRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        skview = SKView(frame: skviewframe)
        skview.backgroundColor = UIColor.clear
        skview.layer.cornerRadius =  0.25 * frame.width
        skview.alpha = 0.8
        skview.layer.masksToBounds = true
        
        let bg = UIView(frame: skviewframe)
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.5
        bg.layer.cornerRadius = 0.25 * frame.width
        
        ContainerView.addSubview(bg)
        ContainerView.addSubview(skview)
        
        indicator.frame = CGRect(x: (frame.width - 30) * 0.5, y: (frame.height - 30) * 0.5, width: 30, height: 30)
        indicator.startAnimating()
        ContainerView.addSubview(indicator)
    }

}
