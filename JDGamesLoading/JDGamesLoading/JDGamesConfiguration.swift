//
//  JDGamesConfiguration.swift
//  JDGamesLoading
//
//  Created by 郭介騵 on 2017/5/11.
//  Copyright © 2017年 james12345. All rights reserved.
//

import UIKit

public class JDGamesConfiguration
{
    
}

public class JDPingPongConfiguration:JDGamesConfiguration{
    var paddle_color:UIColor = UIColor.white
    var ball_color:UIColor = UIColor.white
    
    init(paddlecolor:UIColor,ballcolor:UIColor) {
        paddle_color = paddlecolor
        ball_color = ballcolor
    }
}

public class JDSnackGameConfiguration:JDGamesConfiguration{
    
    var Snack_color:UIColor = UIColor.green
    var Food_color:UIColor = UIColor.white
    var Snack_Speed:CGFloat = 10.0
    
     init(snackcolor:UIColor,foodcolor:UIColor,snackspeed:CGFloat)
    {
        Snack_color = snackcolor
        Food_color = foodcolor
        Snack_Speed = snackspeed
    }
}

public class JDBreaksGameConfiguration:JDGamesConfiguration{
    var paddle_color:UIColor = UIColor.white
    var ball_color:UIColor = UIColor.white
    var block_color:UIColor = UIColor.white
    var RowCount:Int = 1
    var ColumnCount:Int = 3
    
    init(paddlecolor:UIColor,ballcolor:UIColor,blockcolor:UIColor,RowCount:Int,ColumnCount:Int)
    {
        paddle_color = paddlecolor
        ball_color = ballcolor
        block_color = blockcolor
        self.RowCount = RowCount
        self.ColumnCount = ColumnCount
    }
}
