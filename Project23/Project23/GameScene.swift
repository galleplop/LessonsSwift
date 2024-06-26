//
//  GameScene.swift
//  Project23
//
//  Created by Guillermo Suarez on 15/4/24.
//

import SpriteKit
import AVFoundation

enum ForceBomb {
    
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        
        didSet {
            
            self.gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    
    var activeEnemies = [SKSpriteNode]()
    
    var bombSoundEffect: AVAudioPlayer?
    
    let kRangeXPositionEnemy = 64...960
    let kOutsideYPosition = -128
    let kRangeAngularVelocity: ClosedRange<CGFloat> = -3...3
    let kQuarterScreenWidth = 256.0
    let kLargeRangeXVelocity = 8...15
    let kSmallRangeXVelocity = 3...5
    let kRangeYVelocity = 24...32
    let kEnemyVelocityFactor = 40
    let kRadiusColliderEnemy = 64.0
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            
            if let nextSequence = SequenceType.allCases.randomElement() {
                
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            
            self?.tossEnemies()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if activeEnemies.count > 0 {
            
            for (index, node) in activeEnemies.enumerated().reversed() {
                
                if node.position.y < -140 {
                    
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "enemyPlus" {
                        
                        substractLife()
                    }
                    
                    node.name = ""
                    node.removeFromParent()
                    activeEnemies.remove(at: index)
                }
            }
        } else {
            
            if !nextSequenceQueued {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    
                    self?.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard isGameEnded == false else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            
            playSwooshSound()
        }
        
        let nodeAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodeAtPoint {
            
            if node.name == "enemy" || node.name == "enemyPlus" {
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    
                    emitter.position = node.position
                    addChild(emitter)
                    
                    let delay = SKAction.wait(forDuration: 1)
                    emitter.run(SKAction.sequence([delay, .removeFromParent()]))
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                
                node.run(sequence)
                
                score += node.name == "enemy" ? 1:2
                
                if let index = activeEnemies.firstIndex(of: node) {
                    
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    
                    emitter.position = bombContainer.position
                    addChild(emitter)
                    
                    let delay = SKAction.wait(forDuration: 1)
                    emitter.run(SKAction.sequence([delay, .removeFromParent()]))
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let sequence = SKAction.sequence([group, .removeFromParent()])
                
                bombContainer.run(sequence)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func createScore() {
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        
        for i in 0 ..< 3 {
            
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + i * 70), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
        
    }
    
    func createSlices() {
        
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
     
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func playSwooshSound() {
        
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    func redrawActiveSlice() {
        
        //base step
        if activeSlicePoints.count < 2 {
            
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //controll length
        if activeSlicePoints.count > 12 {
            
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func substractLife() {
        
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            
            life = livesImages[0]
        } else if lives == 1 {
            
            life = livesImages[1]
        } else {
            
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 5
        addChild(gameOver)
        
        gameOver.run(SKAction.fadeIn(withDuration: 0.6))
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            
            enemyType = 1
        } else if forceBomb == .always {
            
            enemyType = 0
        }
        
        if enemyType == 0 {
            
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else if enemyType == 3 {
            
            enemy = SKSpriteNode(imageNamed: "penguinPlus")
            enemy.name = "enemyPlus"
            
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        } else {
            
            enemy = SKSpriteNode(imageNamed: "penguin")
            enemy.name = "enemy"
            
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            
        }
        
        //position
        let randomPosition = CGPoint(x: Int.random(in: kRangeXPositionEnemy), y: kOutsideYPosition)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: kRangeAngularVelocity)
        let randomXVelocity: Int
        
        if randomPosition.x < kQuarterScreenWidth {
            
            randomXVelocity = Int.random(in: kLargeRangeXVelocity)
        } else if randomPosition.x < kQuarterScreenWidth * 2 {
            
            randomXVelocity = Int.random(in: kSmallRangeXVelocity)
        } else if randomPosition.x < kQuarterScreenWidth * 3 {
            
            randomXVelocity = -Int.random(in: kSmallRangeXVelocity)
        } else {
            
            randomXVelocity = -Int.random(in: kLargeRangeXVelocity)
        }
        
        let randomYVelocity = Int.random(in: kRangeYVelocity)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: kRadiusColliderEnemy)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * kEnemyVelocityFactor, dy: randomYVelocity * kEnemyVelocityFactor)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies() {
        
        guard isGameEnded == false else { return }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
            
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            
            createEnemy()
        case .twoWithOneBomb:
            
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            
            createEnemy()
            createEnemy()
        case .three:
            
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4.0)) { [weak self] in
                
                self?.createEnemy()
            }
            
        case .fastChain:
            
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3.0)) { [weak self] in
                
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4.0)) { [weak self] in
                
                self?.createEnemy()
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
