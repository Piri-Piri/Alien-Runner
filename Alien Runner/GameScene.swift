//
//  GameScene.swift
//  Alien Runner
//
//  Created by David Pirih on 07.11.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var map: JSTileMap!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        self.backgroundColor = SKColor(red: 0.81, green: 0.91, blue: 0.96, alpha: 1.0)
        
        // Load level
        map = JSTileMap(named: "Level1.tmx")
        self.addChild(map)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
