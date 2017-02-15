//
//  ViewController.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/2/13.
//  Copyright © 2017年 james12345. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        JDGamesLoading(game: .Snacks).show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

