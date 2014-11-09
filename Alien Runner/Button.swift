//
//  Button.swift
//  Tappy Plane
//
//  Created by David Pirih on 25.10.14.
//  Copyright (c) 2014 Piri-Piri. All rights reserved.
//

import UIKit
import SpriteKit

protocol ButtonDelegate {
    
    func buttonPressed(button: Button)
    
}

class Button: SKSpriteNode {
   
    private var fullSizeFrame: CGRect = CGRectNull
    private var isPressed: Bool = false
    
    var delegate: ButtonDelegate!
    
    var pressedScale: CGFloat = 0.0
    var pressedAction: (() -> ())?
    var pressedSound: Sound?
    var enabled: Bool = true {
        didSet {
            if enabled != oldValue {
                if !enabled && disabledTexture != nil {
                    texture = disabledTexture
                }
                else {
                    texture = enabledTexture
                }
                self.userInteractionEnabled = enabled
            }
        }
    }
    var enabledTexture: SKTexture?
    var disabledTexture: SKTexture?
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.enabledTexture = texture
        self.pressedScale = 0.9
        self.userInteractionEnabled = true
        
        /* ensure that button is on top (spritekit/ios8 bug?) */
        self.zPosition = 1.0
    }
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, disableTexture: SKTexture) {
        self.init(texture: texture, color: color, size: size)

        self.disabledTexture = disableTexture
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPressedAction(action: () -> ()) {
        self.pressedAction = action
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.fullSizeFrame = self.frame
        self.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            if isPressed != CGRectContainsPoint(self.fullSizeFrame, touch.locationInNode(self.parent)){
                isPressed = !isPressed
                if isPressed {
                    self.setScale(self.pressedScale)
                    self.pressedSound?.play()
                }
                else {
                    self.setScale(1.0)
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.setScale(1.0)
        self.isPressed = false
        for touch: AnyObject in touches {
            if CGRectContainsPoint(self.fullSizeFrame, touch.locationInNode(self.parent)) {
                // Pressed button
                pressedAction?()
                if delegate != nil {
                    delegate.buttonPressed(self)
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.setScale(1.0)
        self.isPressed = false
    }
    
}
