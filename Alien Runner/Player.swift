//
//  Player.swift
//  Alien Runner
//
//  Created by David Pirih on 07.11.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

import UIKit

class Player: SKSpriteNode {
    
    let kGravity: CGFloat = -0.24
    let kAcceleration: CGFloat = 0.07
    let kMaxSpeed: CGFloat = 3.0
    let kJumpSpeed: CGFloat = 5.5
    let kJumpCutOffSpeed: CGFloat = 2.5
    let kShowCollisionRect = false
    
    var velocity: CGVector = CGVectorMake(0, 0)
    var targetPosition: CGPoint = CGPointZero
    var didJump: Bool = false
    var onGround: Bool = false
    var gravityMultiplier: CGFloat = 1
    
    private var didJumpPrevious: Bool = false
    private var canFlipGravity: Bool = false
    
    override init() {
        let player = SKTexture(imageNamed: "p1_walk01")
        super.init(texture: player, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: player.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gravityFlipped() -> Bool {
        return self.gravityMultiplier == -1
    }
    
    func update() {
        if kShowCollisionRect {
            self.removeAllChildren()
            let box = SKShapeNode()
            box.path = CGPathCreateWithRect(collisionRecAtTarget(), nil)
            box.strokeColor = SKColor.redColor()
            box.lineWidth = 0.1
            box.position = CGPointMake(-targetPosition.x, -targetPosition.y)
            self.addChild(box)
        }
        
        // Apply gravity 
        velocity = CGVectorMake(velocity.dx, velocity.dy + kGravity * gravityMultiplier)
        
        // Apply acceleration
        velocity = CGVectorMake(fmin(kMaxSpeed, velocity.dx + kAcceleration), velocity.dy)
        
        // Prevent ability to flip gravity when player lands on the grounds
        if onGround {
            canFlipGravity = false
        }
        
        if didJump && !didJumpPrevious {
            // Starting a jump
            if onGround {
                // Perform jump
                velocity = CGVectorMake(velocity.dx, kJumpSpeed * gravityMultiplier)
                // Set ability to flip gravity
                canFlipGravity = true
            }
            else if canFlipGravity {
                // Flip gravity
                gravityMultiplier *= -1
                // Prevent further flips until next jump
                canFlipGravity = false
            }
        }
        else if !didJump {
            // Cancel jump
            if gravityFlipped() {
                if velocity.dy < -kJumpCutOffSpeed {
                    velocity = CGVectorMake(velocity.dx, -kJumpCutOffSpeed)
                }
            }
            else {
                if velocity.dy > kJumpCutOffSpeed {
                    velocity = CGVectorMake(velocity.dx, kJumpCutOffSpeed)
                }
            }
        }
        
        // Move Player
        let dx = position.x + velocity.dx
        let dy = position.y + velocity.dy
        targetPosition = CGPointMake(dx, dy)
        
        // Track previous jump state
        self.didJumpPrevious = self.didJump
    }
    
    func collisionRecAtTarget() -> CGRect {
        // Calculate smaller rectangle based on frame
        var collisionRect: CGRect = CGRectInset(self.frame, 4, 2)
        
        // Move rectangle to target position
        let movement = CGPointMake(targetPosition.x - position.x, targetPosition.y - position.y)
        collisionRect = CGRectOffset(collisionRect, movement.x, movement.y - 2)
        
        return collisionRect
    }
    
}
