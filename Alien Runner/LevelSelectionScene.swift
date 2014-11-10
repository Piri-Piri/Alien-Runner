//
//  LevelSelectionScene.swift
//  Alien Runner
//
//  Created by David Pirih on 09.11.14.
//  Copyright (c) 2014 piri-piri. All rights reserved.
//

import UIKit

let kHighestLevel = 3
let kHighestUnlockedLevelKey = "HighestUnlockedLevel"
let kSelectedLevelKey = "SelectedLevel"

class LevelSelectionScene: SKScene, ButtonDelegate {
   
    override init(size: CGSize) {
        super.init(size: size)
        
        // Set background color
        self.backgroundColor = SKColor(red: 0.16, green: 0.27, blue: 0.3, alpha: 1.0)
        
        // Setup title node
        let title = SKLabelNode(fontNamed: "Futura")
        title.text = "Select Level"
        title.fontColor = SKColor(red: 0.518, green: 0.78, blue: 1.0, alpha: 1.0)
        title.fontSize = 40
        title.position = CGPointMake(size.width * 0.5, size.height - 100)
        self.addChild(title)
        
        // Setup layout node
        let layoutNode = SKNode()
        self.addChild(layoutNode)
        
        let buttonDisabledTexture = SKTexture(imageNamed: "LevelLocked")
        var levelUnlocked = NSUserDefaults.standardUserDefaults().integerForKey(kHighestUnlockedLevelKey)
        
        // Add button for levels
        for var i = 1; i <= kHighestLevel; i++ {
            let buttonTexture = SKTexture(imageNamed: "Level\(i)")
            let levelButton = Button(texture: buttonTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: buttonTexture.size(), disableTexture: buttonDisabledTexture)
            levelButton.enabled = i <= levelUnlocked
            levelButton.position = CGPointMake(CGFloat((i - 1) * 50), 0)
            levelButton.name = "\(i)"
            levelButton.delegate = self
            layoutNode.addChild(levelButton)
        }
        
        let layoutFrame: CGRect = layoutNode.calculateAccumulatedFrame()
        layoutNode.position = CGPointMake(size.width * 0.5 - (layoutFrame.size.width * 0.5) - layoutFrame.origin.x, size.height - 170)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed(button: Button) {
        // Save selected level
        NSUserDefaults.standardUserDefaults().setInteger((button.name! as NSString).integerValue, forKey: kSelectedLevelKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Switch to main menu
        if let skView = self.view {
            skView.presentScene(MainMenuScene(size: self.size), transition: SKTransition.pushWithDirection(SKTransitionDirection.Right, duration: 0.6))
        }
    }
    
}
