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
    var mainLayer: TMXLayer!
    var camera: SKNode!
    var player: Player!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        self.backgroundColor = SKColor(red: 0.81, green: 0.91, blue: 0.96, alpha: 1.0)
        
        // Load level
        map = JSTileMap(named: "Level1.tmx")
        mainLayer = map.layerNamed("Main")
        self.addChild(map)
        
        // Setup camera
        camera = SKNode()
        camera.position = CGPointMake(view.frame.size.width * 0.5, view.frame.size.height * 0.5)
        map.addChild(camera)
        
        // Setup Player
        player = Player()
        player.position = getMarkerPosition("Player")
        map.addChild(player)
        
        
    }

    func getMarkerPosition(markerName: String) -> CGPoint {
        var position = CGPointZero
        
        if let markerLayer: TMXObjectGroup = map.groupNamed("Markers") {
            if let marker: NSDictionary = markerLayer.objectNamed(markerName) {
                
                let x = CGFloat(marker.valueForKey("x")!.floatValue)
                let y = CGFloat(marker.valueForKey("y")!.floatValue)

                position = CGPointMake(x, y)
            }
        }
        
        return position
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        player.didJump = true
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            let movement = CGPointMake(location.x - previousLocation.x , location.y - previousLocation.y)
            
            player.position = CGPointMake(player.position.x + movement.x, player.position.y + movement.y)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if touches.anyObject()?.locationInNode(self).x < 50 {
            player.position = getMarkerPosition("Player")
            player.velocity = CGVectorMake(0, 0)
            player.gravityMultiplier = 1
        }
        player.didJump = false
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        player.didJump = false
    }
    
    
    
    func validTileCoord(tileCoord: CGPoint) -> Bool {
        return tileCoord.x >= 0
            && tileCoord.y >= 0
            && tileCoord.x < map.mapSize.width
            && tileCoord.y < map.mapSize.height
    }
    
    func rectForTileCoord(tileCoord: CGPoint) -> CGRect {
        let x = tileCoord.x * map.tileSize.width
        let mapHeight = map.mapSize.height * map.tileSize.height
        let y = mapHeight - ((tileCoord.y + 1) * map.tileSize.height)
        
        return CGRectMake(x, y, map.tileSize.width, map.tileSize.height)
    }
   
    func collide(player: Player, withLayer layer: TMXLayer) {
        // Create coordinate offsets for tiles to check
        let coordOffsets: [CGPoint] = [CGPointMake(0, 1), CGPointMake(0, -1), CGPointMake(1, 0), CGPointMake(-1, 0), CGPointMake(1, -1), CGPointMake(-1, -1), CGPointMake(1, 1), CGPointMake(-1, 1)]
        
        // Get tile grid coord for players position
        let playerCoord = layer.coordForPoint(player.targetPosition)
        
        // Set on ground to false by default
        player.onGround = false
        
        // Looping through the tiles
        for var i = 0; i < 8; i++ {
            // Get player's collision rectangle
            let playerRect: CGRect = player.collisionRecAtTarget()
            // Get the tile coordinate for offset grid loaction
            let offset = coordOffsets[i]
            let tileCoord = CGPointMake(playerCoord.x + offset.x, playerCoord.y + offset.y)
            
            var gid:Int32 = 0
            if validTileCoord(tileCoord) {
                gid = layer.layerInfo.tileGidAtCoord(tileCoord)
            }
            
            // Get gid for the tile at coordinate
            if gid != 0 {
                // Get intersection rectangle for player and tile
                let intersection: CGRect = CGRectIntersection(playerRect, rectForTileCoord(tileCoord))
                
                if !CGRectIsEmpty(intersection) {
                    // Do we move the player horizontally or vertically
                    let resolveVertically: Bool = offset.x == 0 || (offset.y != 0 && intersection.size.height < intersection.size.width)
                    
                    var positionAdjustment = CGPointZero
                    if resolveVertically {
                        // Calculate the distance we need to move the player
                        positionAdjustment.y = intersection.size.height * offset.y
                        // Stop player moving vertically
                        player.velocity = CGVectorMake(player.velocity.dx, 0)
                        
                        //
                        if offset.y == player.gravityMultiplier {
                            // Player is touching the ground
                            player.onGround = true
                        }
                    }
                    else {
                        positionAdjustment.x = intersection.size.width * -offset.x
                        // Stop player moving horizontally
                        player.velocity = CGVectorMake(0, player.velocity.dy)
                    }
                    
                    player.targetPosition = CGPointMake(player.targetPosition.x + positionAdjustment.x, player.targetPosition.y + positionAdjustment.y)
                }
            }
        }
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Update player
        player.update()
        
        // Collide player with the world
        collide(player, withLayer: mainLayer)
        
        // Move player
        player.position = player.targetPosition
        
        // Update position of camera
        camera.position = CGPointMake(player.position.x + (self.frame.size.width * 0.25), player.position.y)
        updateView()
    }
    
    func updateView() {
        // Calculate clamped x and y locations
        var x = fmax(camera.position.x, self.frame.size.width * 0.5)
        var y = fmax(camera.position.y, self.frame.size.height * 0.5)
        x = fmin(x, map.mapSize.width * map.tileSize.width - (self.frame.size.width * 0.5))
        y = fmin(y, map.mapSize.height * map.tileSize.height - (self.frame.size.height * 0.5))
        
        // Center view on position of camera in the world
        map.position = CGPointMake((self.frame.size.width * 0.5) - x, (self.frame.size.height * 0.5) - y)
    }
    
}
