//
//  Player.swift
//  Alien Runner
//
//  Created by David Pirih on 07.11.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

import UIKit

enum PlayerState: Int {
    case Running = 0
    case Jumping
    case Hurt
}

class Player: SKSpriteNode {
    
    let kGravity: CGFloat = -0.24
    let kAcceleration: CGFloat = 0.07
    let kMaxSpeed: CGFloat = 3.5
    let kJumpSpeed: CGFloat = 5.5
    let kJumpCutOffSpeed: CGFloat = 2.5
    
    let kShowCollisionRect = false
    
    var velocity: CGVector = CGVectorMake(0, 0)
    var targetPosition: CGPoint = CGPointZero
    var didJump: Bool = false
    var onGround: Bool = false
    var gravityMultiplier: CGFloat = 1 {
        didSet {
            // Set the texture orientation to match the pull of gravity
            self.yScale = gravityMultiplier
        }
    }
    var currentState: PlayerState = .Running {
        didSet {
            if currentState != oldValue {
                if oldValue == .Running {
                    self.removeActionForKey("Run")
                }
                
                switch currentState {
                case .Running:
                    self.runAction(runningAnimation, withKey: "Run")
                case .Jumping:
                    self.texture = SKTexture(imageNamed: "p1_jump")
                case .Hurt:
                    self.texture = SKTexture(imageNamed: "p1_hurt")
                default:
                    println("Error: invalid player state: \(currentState)")
                }
            }
        }
    }
    
    private var didJumpPrevious: Bool = false
    private var canFlipGravity: Bool = false
    private var runningAnimation: SKAction!
    
    override init() {
        let player = SKTexture(imageNamed: "p1_walk01")
        super.init(texture: player, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: player.size())
        
        // Create array for frames for run animation
        var walkFrames = NSMutableArray()
        for var i = 1; i < 12; i++ {
            let frame = SKTexture(imageNamed: String(format: "p1_walk%02d", i))
            
            walkFrames.addObject(frame)
        }
        
        let animation = SKAction.animateWithTextures(walkFrames, timePerFrame: (1.0/15.0), resize: false, restore: false)
        self.runningAnimation = SKAction.repeatActionForever(animation)
        self.runAction(runningAnimation, withKey: "Run")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gravityFlipped() -> Bool {
        return self.gravityMultiplier == -1
    }
    
    func kill() {
        currentState = .Hurt
        velocity = CGVectorMake(0, kJumpSpeed * kGravity)
    }
    
    
    func collisionRecAtTarget() -> CGRect {
        // Calculate smaller rectangle
        /*
            // The size of the frame property is smaller than size property due empty pixel are remove by spritekit
            var collisionRect: CGRect = CGRectInset(self.frame, 4, 2)
        */
        var collisionRect: CGRect = CGRectMake(targetPosition.x - (size.width * anchorPoint.x) + 4, targetPosition.y - (size.height * anchorPoint.y), size.width - 8, size.height - 4)
        
        if gravityFlipped() {
            // Move the rectangle up because the bottom is now at the top in parent coords
            collisionRect.origin.y += 4
        }
        
        return collisionRect
    }
    
    func update() {
        if kShowCollisionRect {
            self.removeAllChildren()
            let box = SKShapeNode()
            var rect: CGRect = collisionRecAtTarget()
            if gravityFlipped() {
                rect.origin.y -= 4
            }
            box.path = CGPathCreateWithRect(rect, nil)
            box.strokeColor = SKColor.redColor()
            box.lineWidth = 0.1
            box.position = CGPointMake(-targetPosition.x, -targetPosition.y)
            self.addChild(box)
        }
        
        // Apply gravity 
        velocity = CGVectorMake(velocity.dx, velocity.dy + kGravity * gravityMultiplier)
        
        if currentState != .Hurt {
            // Apply acceleration
            velocity = CGVectorMake(fmin(kMaxSpeed, velocity.dx + kAcceleration), velocity.dy)
            
            // Prevent ability to flip gravity when player lands on the grounds
            if onGround {
                canFlipGravity = false
                currentState = .Running
            }
            else {
                currentState = .Jumping
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
        }
        
        // Move Player
        let dx = position.x + velocity.dx
        let dy = position.y + velocity.dy
        targetPosition = CGPointMake(dx, dy)
        
        // Track previous jump state
        self.didJumpPrevious = self.didJump
    }
}
