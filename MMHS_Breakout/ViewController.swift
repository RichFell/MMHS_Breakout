//
//  ViewController.swift
//  MMHS_Breakout
//
//  Created by Richard Fellure on 7/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

extension UIColor
    {
    class func ballColor() -> UIColor
    {
        return UIColor(red: 98/255.0, green: 255/255.0, blue: 57/255.0, alpha: 1.0)
    }
    class func paddleColor() -> UIColor
    {
        return UIColor(red: 205/205.0, green: 205/205.0, blue: 205/205.0, alpha: 1.0)
    }
    class func blockColor() -> UIColor
    {
        return UIColor(red: 249/255.0, green: 99/255.0, blue: 210/255.0, alpha: 1.0)
    }
    class func blockHitColor() -> UIColor
    {
        return UIColor(red: 222/255.0, green: 245/255.0, blue: 32/255.0, alpha: 1.0)
    }

}

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    var dynamicAnimator = UIDynamicAnimator()
    var pushBehavior = UIPushBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var allViewsArray = [BlockView]()
    var blockArray = [BlockView]()
    var paddleArray = [BlockView]()
    var ballArray = [BlockView]()
    var deletedBlockArray = [BlockView]()
    var restartControl : Int = 0

    @IBOutlet var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(frame: CGRect(origin:CGPoint(x: 0.0, y: 0.0), size: view.frame.size))
        imageView.image = UIImage(named: "SpaceImage")
        view.addSubview(imageView)

        view.bringSubviewToFront(button)  

          createBlocksPaddleAndBall()
        button.tintColor = UIColor.blockColor()

    }

    //Function to progmatically create our blocks, paddle, and ball so that later on we can change sizing of these if we wish for later levels
    //If this is being made on a iPad dimensions number of blocks across the view controller should be adjusted accordingly to adjust for larger screen sizes
    func createBlocksPaddleAndBall()
    {
        var x = 5
        var y = 20
        for e in 1...8
        {
            for i in 1...7
            {
                let block = createBlock(x, y: y, width: 40, height: 20)
                block.backgroundColor = UIColor.blockColor()
                restartControl++

                x = x + 45
            }
            x = 5
            y = y + 25
        }

        createPaddleAndBall(160, paddleY: 450, paddleWidth: 60, paddleHeight: 20, ballX: 160, ballY: 300, ballWidth: 10, ballHeight: 10)
    }


    //Function that setups our UIDynamicAnimator, and setups all of our object's Dynamic Behavior
    func addDynamicBehavior(ballView: UIView, paddleView: UIView)
    {
        dynamicAnimator = UIDynamicAnimator(referenceView: view)

        collisionBehavior = UICollisionBehavior(items: allViewsArray)
        collisionBehavior.collisionMode = UICollisionBehaviorMode.Everything
        collisionBehavior.collisionDelegate = self
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(collisionBehavior)

        let paddleBehavior = UIDynamicItemBehavior(items: [paddleView])
        paddleBehavior.allowsRotation = false
        paddleBehavior.density = 10000
        paddleBehavior.elasticity = 1
        dynamicAnimator.addBehavior(paddleBehavior)

        ballBehavior = UIDynamicItemBehavior(items: [ballView])
        ballBehavior.allowsRotation = false
        ballBehavior.elasticity = 1
        ballBehavior.friction = 0.0
        ballBehavior.resistance = 0.0
        dynamicAnimator.addBehavior(ballBehavior)

        let blockBehavior = UIDynamicItemBehavior(items: blockArray)
        blockBehavior.allowsRotation = false
        blockBehavior.density = 10000
        blockBehavior.elasticity = 1
        dynamicAnimator.addBehavior(blockBehavior)

    }

    //Function that will set our push to happen to the ball, and  give the push to our ball to make it start moving
    func givePush(ballView: UIView)
    {
        pushBehavior = UIPushBehavior(items: [ballView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 0.4)
        pushBehavior.magnitude = 0.03
        pushBehavior.active = true
        dynamicAnimator.addBehavior(pushBehavior)
    }


    //Action that uses the UIPanGestureRecognizer to move the paddle
    @IBAction func dragPaddle(panGesturRecognizer: UIPanGestureRecognizer)
    {
        let paddle = paddleArray[0]
        paddle.center = CGPointMake(panGesturRecognizer.locationInView(view).x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }


//    CollisionBehaviorDelegate method that gets called when an object makes contact with the boundary of our view
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: NSCopying!, atPoint p: CGPoint)
    {

        println(identifier)
        let ball = ballArray[0]
        let paddle = paddleArray[0]

        if ball.center.y >  paddle.center.y
        {
            ball.center = view.center
            ballBehavior.resistance = 100

            dynamicAnimator.updateItemUsingCurrentState(ball)

            restartAfterLose()
        }
    }

    //UICollisionBehaviorDelegate method that gets called when an obect makes contact with another object
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item1: UIView!, withItem item2: UIView!, atPoint p: CGPoint)
    {
        let ball = ballArray[0]

        for block in blockArray
        {
            if item1 == block && item2 == ball
            {
                println("evaluate true")

                if block.numberOfHits == 1
                {
                    block.hidden = true
                    collisionBehavior.removeItem(block)
                    dynamicAnimator.updateItemUsingCurrentState(block)

                    deletedBlockArray.append(block)

                    if deletedBlockArray.count == restartControl
                    {
                        resetAfterWin()
                        deletedBlockArray.removeAll(keepCapacity: false)
                    }
                }
                else
                {
                    block.backgroundColor = UIColor.blockHitColor()
                }
                block.numberOfHits++
            }
        }
    }


    //Function to control restarting a game after the ball hits the bottom of the screen
    func restartAfterLose()
    {
        for block in deletedBlockArray
        {
            block.hidden = false
            collisionBehavior.addItem(block)
            dynamicAnimator.updateItemUsingCurrentState(block)
            block.backgroundColor = UIColor.blockColor()
            block.numberOfHits = 0
        }

        for blockView in blockArray
        {
            if blockView.numberOfHits > 0
            {
                blockView.numberOfHits = 0
                blockView.backgroundColor = UIColor.blockColor()
            }
        }

        button.hidden = false
        deletedBlockArray.removeAll(keepCapacity: false)
    }

    //Helper function to reset the game after all of the blocks have been deleted
    func resetAfterWin()
    {

        ballBehavior.resistance = 100

        let ball = ballArray[0]
        dynamicAnimator.updateItemUsingCurrentState(ball)
        ballArray.removeAll(keepCapacity: false)
        deletedBlockArray.removeAll(keepCapacity: false)
        button.hidden = false
        createLevelTwo()

    }

    //IBAction attached to our button that will dictate starting the game, and restarting
    @IBAction func pressedDownStart(sender: AnyObject) {
        button.hidden = true
        let ball = ballArray[0]

        ballBehavior.resistance = 0.0
        dynamicAnimator.updateItemUsingCurrentState(ball)
        givePush(ball)
    }

    //Helper function to create the blocks
    func createBlock(x:Int, y: Int, width: Int, height: Int)-> BlockView
    {
        let block = BlockView(frame: CGRect(x: x, y: y, width: width, height: height))
        view.addSubview(block)
        view.bringSubviewToFront(block)
        allViewsArray.append(block)
        blockArray.append(block)

        return block
    }

    //Helper function to create the paddle and ball
    func createPaddleAndBall(paddleX: Int, paddleY:Int, paddleWidth: Int, paddleHeight: Int, ballX:Int, ballY:Int, ballWidth:Int, ballHeight:Int)
    {
        let paddle = BlockView(frame: CGRect(x: paddleX, y: paddleY, width: paddleWidth, height: paddleHeight))
        view.addSubview(paddle)
        view.bringSubviewToFront(paddle)
        allViewsArray.append(paddle)
        paddle.backgroundColor = UIColor.paddleColor()

        paddle.layer.cornerRadius = 10.0

        paddleArray.append(paddle)

        let ball = BlockView(frame: CGRect(x: ballX, y: ballY, width: ballWidth, height: ballHeight))
        view.addSubview(ball)
        view.bringSubviewToFront(ball)
        allViewsArray.append(ball)
        ball.backgroundColor = UIColor.ballColor()

        ball.layer.cornerRadius = 5.0
        ballArray.append(ball)

        addDynamicBehavior(ball, paddleView: paddle)

        let snapBehavior = UISnapBehavior(item: ball, snapToPoint: CGPointMake(160, 160))

    }

    //Function to create our second level
    func createLevelTwo()
    {

        var x = 5
        var y = 13

        for var e = 0; e < 12; e++
        {
            for i in 1...9
            {
                if i % 2 == 0
                {
                    let block = createBlock(x, y: y, width: 20, height: 10)
                    block.backgroundColor = UIColor.blockColor()
                    x = x + 20

                }
                else
                {
                    let block = createBlock(x, y: y, width: 30, height: 10)
                    block.backgroundColor = UIColor.blockHitColor()
                    x = x + 30
                }
            }
            x = 2
            y = y + 10

        }
        createPaddleAndBall(160, paddleY: 450, paddleWidth: 30, paddleHeight: 20, ballX: 300, ballY: 300, ballWidth: 8, ballHeight: 8)

    }
}

