//
//  ViewController.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/2/13.
//  Copyright © 2017年 james12345. All rights reserved.
//


import UIKit



class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        JDGamesLoading(game: .PingPong).show()
    }
   
}

