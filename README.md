# JDGamesLoading
(IOS)Let User Play Game When Loading
***
# Introduction
First, thanks everyone for supporting my last game loading, **JDBreaksLoading**.

Now, I make more game. After this, I won't make another repositry about gameloading.Now on, New game will be update in this reop.
So ~ **Star & Watch this reop for more game!!**

Still, don't make user wait too long to play the game~

Thanks for using.

<img src="/../master/Readme_img/Logomakr_3Y8BMT.png" width="60%">

# Installation
1. **Cocoapod**

	Now, You can use Cocoapod !
	
	```
	pod 'JDGamesLoading'
	```
2. **Fork my reop.**


# Usage

Now,It's more easier to call the loading then JDBreakLoading.

Just One Line:

```Swift
  JDGamesLoading(game: .Breaks).show()
```
For Dismiss:

```Swift
  JDGamesLoading.dismiss()
```

### GameTypes
* **.Snacks**:
<img src="/../master/Readme_img/SnackGameDemo.gif" width="40%">

* **.PingPong**:
<img src="/../master/Readme_img/PingPongDemo.gif" width="40%">

* **.Breaks**:
<img src="/../master/Readme_img/BreakGameDemo.gif" width="40%">

* **.Puzzle**:
<img src="/../master/Readme_img/JDPuzzleDemo.gif" width="40%">


### Game Configuration 
Because there are more game now, 
So I change the way to set the game configuration.

**Call .withConfiguration(configuration:) Brfore .show()**

```Swift
let snackconfig = JDSnackGameConfiguration(snackcolor: UIColor.blue, foodcolor: UIColor.brown, snackspeed: 50)
JDGamesLoading(game: .Snacks).withConfiguration(configuration: snackconfig).show()
```
* **JDSnackGameConfiguration**:

```Swift
var Snack_color:UIColor = UIColor.green
var Food_color:UIColor = UIColor.white
var Snack_Speed:CGFloat = 10.0
```

* **JDBreaksGameConfiguration**:

```Swift
 var paddle_color:UIColor = UIColor.white
 var ball_color:UIColor = UIColor.white
 var block_color:UIColor = UIColor.white
 var RowCount:Int = 1
 var ColumnCount:Int = 3
```

* **JDPingPongConfiguration**:

```Swift
 var paddle_color:UIColor = UIColor.white
 var ball_color:UIColor = UIColor.white
```


