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
    var paddleBehavior = UIDynamicItemBehavior()
    var ballBehavior = UIDynamicItemBehavior()
    var blockBehavior = UIDynamicItemBehavior()
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        createBlocksPaddleAndBall()

    }

    func createBlocksPaddleAndBall()
    {
        var x = 5
        var y = 20
        for e in 1...10
        {
            for i in 1...7
            {
                let block = UIView(frame: CGRect(x: x, y: y, width: 40, height: 20))
                println(block)

                block.backgroundColor = UIColor.redColor()
                view.addSubview(block)
                view.bringSubviewToFront(block)
                x = x + 45
            }
            x = 5
            y = y + 25
        }

        let paddle = UIView(frame: CGRect(x: 160, y: 450, width: 40, height: 20))
        paddle.backgroundColor = UIColor.blueColor()
        view.addSubview(paddle)
        view.bringSubviewToFront(paddle)

        let ball = UIView(frame: CGRect(x: 160, y: 300, width: 10, height: 10))
        ball.backgroundColor = UIColor.blackColor()
        view.addSubview(ball)
        view.bringSubviewToFront(ball)



    }
}

