//
//  ViewController.swift
//  MMHS_Breakout
//
//  Created by Richard Fellure on 7/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    var dynamicAnimator = UIDynamicAnimator()
    var pushBehavior = UIPushBehavior()
    var collisionBehavior = UICollisionBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var allViewsArray = [UIView]()
    var blockArray = [UIView]()
    var paddleArray = [UIView]()
    var ballArray = [UIView]()
    var deletedBlockArray = [UIView]()

    @IBOutlet var button: UIButton
    override func viewDidLoad() {
        super.viewDidLoad()

        createBlocksPaddleAndBall()

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
                let block = UIView(frame: CGRect(x: x, y: y, width: 40, height: 20))

                block.backgroundColor = UIColor.redColor()
                view.addSubview(block)
                view.bringSubviewToFront(block)

                blockArray += block
                x = x + 45
            }
            x = 5
            y = y + 25
        }

        let paddle = UIView(frame: CGRect(x: 160, y: 450, width: 60, height: 20))
        paddle.backgroundColor = UIColor.blueColor()
        view.addSubview(paddle)
        view.bringSubviewToFront(paddle)
        paddleArray += paddle

        let ball = UIView(frame: CGRect(x: 160, y: 300, width: 10, height: 10))
        ball.backgroundColor = UIColor.blackColor()
        view.addSubview(ball)
        view.bringSubviewToFront(ball)
        ballArray += ball

        allViewsArray += [paddle, ball]
        allViewsArray += blockArray

        addDynamicBehavior(ball, paddleView: paddle)


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


    //CollisionBehaviorDelegate function that gets called when an object makes contact with the boundary of our view
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item: UIDynamicItem!, withBoundaryIdentifier identifier: NSCopying!, atPoint p: CGPoint)
    {
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

    //UICollisionBehaviorDelegate function that gets called when an obect makes contact with another object
    func collisionBehavior(behavior: UICollisionBehavior!, beganContactForItem item1: UIView!, withItem item2: UIView!, atPoint p: CGPoint)
    {
        let ball = ballArray[0]

        for block in blockArray
        {
            if item1 == ball && item2 == block
            {
                block.hidden = true
                collisionBehavior.removeItem(block)
                dynamicAnimator.updateItemUsingCurrentState(block)

                deletedBlockArray += block
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

        }

        button.hidden = false
        deletedBlockArray.removeAll(keepCapacity: false)
    }

    //IBAction attached to our button that will dictate starting the game, and restarting
    @IBAction func pressedDownStart(sender: AnyObject) {
        button.hidden = true
        let ball = ballArray[0]

        ballBehavior.resistance = 0.0
        dynamicAnimator.updateItemUsingCurrentState(ball)
        givePush(ball)
    }


 

}

