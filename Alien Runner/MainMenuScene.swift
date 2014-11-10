//
//  MainMenuScene.swift
//  Alien Runner
//
//  Created by David Pirih on 09.11.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

import UIKit

class MainMenuScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Init audio
        SoundManager.sharedManager().prepareToPlay()
        
        // Set background color
        self.backgroundColor = SKColor(red: 0.16, green: 0.27, blue: 0.3, alpha: 1.0)
        
        // Setup title node
        let title = SKLabelNode(fontNamed: "Futura")
        title.text = "Alien Runner"
        title.fontColor = SKColor(red: 0.518, green: 0.78, blue: 1.0, alpha: 1.0)
        title.fontSize = 40
        title.position = CGPointMake(size.width * 0.5, size.height - 100)
        self.addChild(title)
        
        // Setup Alien
        let alien = Player()
        alien.position = CGPointMake(size.width * 0.5, size.height - 150)
        alien.currentState = .Running
        self.addChild(alien)
        
        // Setup label node to display level        
        let levelDisplay = SKLabelNode(fontNamed: "Futura")
        levelDisplay.text = "Level \(NSUserDefaults.standardUserDefaults().integerForKey(kSelectedLevelKey))"
        levelDisplay.fontColor = SKColor(red: 0.518, green: 0.78, blue: 1.0, alpha: 1.0)
        levelDisplay.fontSize = 15
        levelDisplay.position = CGPointMake(size.width * 0.5, size.height - 195)
        self.addChild(levelDisplay)
        
        // Setup play button
        let playButtonTexture = SKTexture(imageNamed: "ButtonPlay")
        let playButton = Button(texture: playButtonTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: playButtonTexture.size())
        playButton.position = CGPointMake(size.width * 0.5 - 55, 90)
        playButton.setPressedAction(pressedPlayButton)
        playButton.pressedSound = Sound(named: "Click.caf")
        self.addChild(playButton)
        
        // Setup level button
        let levelButtonTexture = SKTexture(imageNamed: "ButtonLevel")
        let levelButton = Button(texture: levelButtonTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: levelButtonTexture.size())
        levelButton.position = CGPointMake(size.width * 0.5 + 55, 90)
        levelButton.setPressedAction(pressedLevelButton)
        levelButton.pressedSound = Sound(named: "Click.caf")
        self.addChild(levelButton)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pressedPlayButton() {
        if let skView = self.view {
            skView.presentScene(GameScene(size: self.size))
        }
    }
    
    func pressedLevelButton() {
        if let skView = self.view {
            skView.presentScene(LevelSelectionScene(size: self.size), transition: SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.6))
        }
    }
    
}
