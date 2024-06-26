//
//  GameScene.swift
//  Project17
//
//  Created by Guillermo Suarez on 10/4/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    var isPlayerGrabbed = false
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var countEnemies = 0
    
    @objc func createEnemy() {
        
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        countEnemies += 1
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        
        if countEnemies != 0 && countEnemies % 20 == 0 {
            
            //upper bound of 0.2
            let newTimerEnemies = Double.maximum(1.0 - (Double(countEnemies / 20) * 0.1), 0.2)
            
            gameTimer?.invalidate()
            print("newTimerEnemies = \(newTimerEnemies)")
            gameTimer = Timer.scheduledTimer(timeInterval: newTimerEnemies, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    //MARK: - SKScene
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        countEnemies = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        for node in children {
            
            if node.position.x < -300 {
                
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if objects.contains(player) {
            
            isPlayerGrabbed = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if isPlayerGrabbed {
            
            if location.y < 100 {
                
                location.y = 100
            } else if location.y > 668 {
                
                location.y = 668
            }
            
            player.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isPlayerGrabbed = false
    }
    
    //MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
    }
}
