//
//  GameScene.swift
//  SpaceForce Demo
//
//  Created by JohelCzarco on 6/18/19.
//  Copyright © 2019 JohelCzarco. All rights reserved.
//  Background music my Kevin Macleod,CreativeCommons 3.0

import SpriteKit

@objcMembers

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player.png")
    var touchingPlayer : Bool = false
    var gameTimer : Timer?
    var nodeNum : Int = 0
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    var hasBeenHitOnce : Bool = false // detect first crash, reset every scene
    let restartButton = SKSpriteNode(imageNamed: "reset.png")
    let livesLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")

    var score = 0 {
        didSet{
            scoreLabel.text = "SCORE : \(score)"
        }
    }
    let shockWaveAction : SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(by: 50, duration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        let sequence = SKAction.sequence([growAndFadeAction, SKAction.removeFromParent()])
        return sequence
    }()
    
    override func didMove(to view: SKView) {
        // scene ready to run, background
        let background = SKSpriteNode(imageNamed: "space.png")
        background.zPosition = -1 // below other nodes
        addChild(background)
         addChild(music)
        // space dust stuff
        if let particles = SKEmitterNode(fileNamed: "SpaceDust"){
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        // player stuff
        player.position.x = -300
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 0 // 1??
        player.physicsBody?.contactTestBitMask = 1
        player.name = "spaceship"
        addChild(player)
        // score Label
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 250
        scoreLabel.position.x = 0
        score = 0
        addChild(scoreLabel)
        // lives label
        livesLabel.zPosition = 3
        livesLabel.position.x = -280
        livesLabel.position.y = -240
        livesLabel.text = "Lives : \(PlayerLives.lives)"
        addChild(livesLabel)
       
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        physicsWorld.contactDelegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        let location = touch.location(in: self) // return loc inside scene
        let tappedNodes = nodes(at: location)// nodes precisely in that loc
        if tappedNodes.contains(player) {touchingPlayer = true}
        
        if tappedNodes.contains(restartButton) {
            scene?.view!.isPaused = false
            PlayerLives.lives = 3
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            restartButton.run(fadeAction)
            restartGame()
            //restartButton.isHidden = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else {return}
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = location
        // smoke from spacechsip
//        if let smoke = SKEmitterNode(fileNamed: "mySmoke") {
//            smoke.position = player.position
//            smoke.numParticlesToEmit = 5
//            smoke.physicsBody?.categoryBitMask = 0
//            smoke.physicsBody?.contactTestBitMask = 0
//            addChild(smoke)
//
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if player.parent != nil { // player hasn't been killed
            score += 1
        }
        // containing player between boundries
        if player.position.x < -400 {
            player.position.x = -400
        } else if player.position.x > 400 {
            player.position.x = 400
        }
        
        if player.position.y < -300 {
            player.position.y = -300
        } else if player.position.y > 300 {
            player.position.y = 300
        }
        // remove old nodes
        for node in children {
            if node.position.x < -550 {
                node.removeFromParent()
            }
        }
    }
    
    func createEnemy() {
        // Enemy based on random image
        let astIndex : Int = Int.random(in: 0 ... 2)
        let asteroid : SKSpriteNode
        
        if astIndex == 0 {
            asteroid = SKSpriteNode(imageNamed: "redAsteroid.png")
            modEnemy(asteroid: asteroid)
        } else if astIndex == 1 {
            asteroid = SKSpriteNode(imageNamed: "greyAsteroid.png")
            modEnemy(asteroid: asteroid)
        } else if astIndex == 2 {
            asteroid = SKSpriteNode(imageNamed: "blackAsteroid.png")
            modEnemy(asteroid: asteroid)
        } else {return}
    }
    
    func modEnemy(asteroid : SKSpriteNode){
        asteroid.name = "asteroid"
        let angRotation : Double = Double.random(in: 0.5 ... 2.9)// random rotation speed
        //print(angRotation)
        asteroid.position = CGPoint(x: 320, y: Int.random(in: -260 ... 260))
        asteroid.zPosition = 1
        asteroid.physicsBody?.contactTestBitMask = 1
        asteroid.physicsBody?.categoryBitMask = 0 // avoid collision with itself
        addChild(asteroid)
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: -480, dy: 0)
        asteroid.physicsBody?.linearDamping = 0
        // asteroid rotation
        let oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: angRotation)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
       // if (nodeA.name == "spaceship" && nodeB.name == "asteroid") {print("collision")}
    
        if (nodeA == player && hasBeenHitOnce == false) {
            playerHit(nodeB)
            hasBeenHitOnce = true
            PlayerLives.beenHit()
            
        } else if (nodeB == player && hasBeenHitOnce == false) {
            PlayerLives.beenHit()
            playerHit(nodeA)
            hasBeenHitOnce = true
            
        }
    }
    
    func playerHit(_ node: SKNode){
        //playerLives.beenHit()
        print("lives : \(PlayerLives.lives)")
        print("hasBeenHitOnce : \(hasBeenHitOnce)")
        
        explosionEffects(node)
        if PlayerLives.lives > 0 {
            restartGame()
        } else if PlayerLives.lives == 0 {
            gameOver()
            displayRestartButton()
        }
    }
    
    func gameOver(){
        print("gameOver")
        player.removeFromParent()
        music.removeFromParent()
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.zPosition = 10
        gameOver.position.x = 0
        addChild(gameOver)
        scene?.view!.isPaused = true
    }
    
    func displayRestartButton(){
        
        restartButton.zPosition = 5
        restartButton.position.x = 250
        restartButton.position.y = -200
        addChild(restartButton)
    }
    
    func restartGame (){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
    
    func explosionEffects(_ node : SKNode){
        let fadeAction = SKAction.fadeOut(withDuration: 0.5)
        player.run(fadeAction)
        let soundExplosion = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(soundExplosion)
        if let explosion = SKEmitterNode(fileNamed: "explosion.sks") {
            explosion.position = player.position
            explosion.zPosition = 3
            addChild(explosion)
        }
        let shockwave = SKShapeNode(circleOfRadius: 1)
        shockwave.position = player.position
        addChild(shockwave)
        shockwave.run(shockWaveAction)
        
    }
}
