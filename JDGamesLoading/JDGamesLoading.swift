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

enum GamePack
{
    case Breaks
    case Snacks
}


class JDGamesLoading
{
    var ChoosingGame:GamePack = .Breaks
    let PrsentedViewController:JDLoadingViewController = JDLoadingViewController()
    
    init(game:GamePack)
    {
        ChoosingGame = game
    }
    
    func show()
    {
        PrsentedViewController.GameType = ChoosingGame
        if let VC = UIApplication.topViewController() {
            PrsentedViewController.modalPresentationStyle = .overCurrentContext
            PrsentedViewController.modalTransitionStyle = .coverVertical
            
            VC.present(PrsentedViewController, animated: true, completion: nil)
        }
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
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        //
        frame = CGRect(x: self.view.frame.width * 1/4 , y: self.view.frame.height * 1/2 - self.view.frame.width * 1/4 , width: self.view.frame.width * 1/2 , height: self.view.frame.width * 1/2)
        //
        initView()
        
        let skviewframe:CGRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        if(GameType == .Breaks)
        {
            skscene = JDBreaksScene(size: skviewframe.size)
        }
        else if(GameType == .Snacks)
        {
            skscene = JDSnackScene(size: skviewframe.size)
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
