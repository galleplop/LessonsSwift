//
//  GameScene.swift
//  Project26
//
//  Created by Guillermo Suarez on 22/4/24.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        
        didSet {
            
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    
    var level = 1
    var levelNodes: [SKNode] = []
    
    //MARK: - SKScene
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        score = 0
        
        addChild(scoreLabel)
        
        
        loadLevel(levelNum: level)
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            
            physicsWorld.gravity = CGVector(dx: diff.x/100, dy: diff.y/100)
        }
        #else
        
        if let accelerometerData = motionManager?.accelerometerData {
            
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        lastTouchPosition = nil
    }
    
    //MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            
            playerCollided(with: nodeB)
        } else if nodeB == player {
            
            playerCollided(with: nodeA)
        }
    }
    
    //MARK: Methods
    
    func createPlayer() {
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    func playerCollided(with node: SKNode) {
        
        if node.name == "vortex" {
            
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let sequence = SKAction.sequence([move, scale, .removeFromParent()])
            
            player.run(sequence) { [weak self] in
                
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level
            
            if level == 1 {
                
                level = 2
                loadLevel(levelNum: level)
                player.removeFromParent()
                createPlayer()
            }
            
        }
    }
    
    func loadLevel(levelNum: Int) {
        
        guard let levelURL = Bundle.main.url(forResource: "level\(levelNum)", withExtension: "txt") else { fatalError("Could not find level\(levelNum).txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load level\(levelNum).txt from the app bundle.") }
        
        for levelNode in levelNodes {
            
            levelNode.removeFromParent()
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            
            for (column, letter) in line.enumerated() {
                
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                let node: SKNode?
                
                if letter == "x" {
                    //load a wall
                    node = createBlock(at: position)
                } else if letter == "v" {
                    //load a vortex
                    node = createVortex(at: position)
                } else if letter == "s" {
                    //load start point
                    node = createStart(at: position)
                } else if letter == "f" {
                    //load finish point
                    node = createFinish(at: position)
                } else if letter == " " {
                    //this is an empty space - do nothing
                    node = nil
                } else {
                    
                    fatalError("Unknow level letter: \(letter)")
                }
                
                if let node = node {
                    
                    levelNodes.append(node)
                    addChild(node)
                }
            }
        }
    }
    
    func createBlock(at position: CGPoint) -> SKNode {
        
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        return node
    }
    
    func createVortex(at position: CGPoint) -> SKNode {
        
        let node = SKSpriteNode(imageNamed: "vortex")
        node.position = position
        node.name = "vortex"
        
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func createStart(at position: CGPoint) -> SKNode {
        
        let node = SKSpriteNode(imageNamed: "star")
        node.position = position
        node.name = "star"
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func createFinish(at position: CGPoint) -> SKNode {
        
        let node = SKSpriteNode(imageNamed: "finish")
        node.position = position
        node.name = "finish"
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
}
