//
//  ViewController.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/2/13.
//  Copyright © 2017年 james12345. All rights reserved.
//


import UIKit



class ViewController: UIViewController {
    
    var jdgamesloading:JDGamesLoading?
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func ShowSnackGames(_ sender: Any) {
        //let snackconfig:JDSnackGameConfiguration = JDSnackGameConfiguration(snackcolor: UIColor.blue, foodcolor: UIColor.brown, snackspeed: 50)
        jdgamesloading = JDGamesLoading(game: .Snacks)
        jdgamesloading?.demoPresent()
    }
   
    @IBAction func ShowBreakGame(_ sender: Any) {
        jdgamesloading = JDGamesLoading(game: .Breaks)
        jdgamesloading?.demoPresent()
    }
    
    @IBAction func ShowPingPong(_ sender: Any) {
        jdgamesloading = JDGamesLoading(game: .PingPong)
        jdgamesloading?.demoPresent()
    }
    
    @IBAction func ShowPuzzle(_ sender: Any) {
        jdgamesloading = JDGamesLoading(game: .Puzzle)
        jdgamesloading?.demoPresent()
    }
    
}
