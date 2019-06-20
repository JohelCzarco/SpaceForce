//
//  GameScene.swift
//  SpaceForce Demo
//
//  Created by JohelCzarco on 6/18/19.
//  Copyright © 2019 JohelCzarco. All rights reserved.
//

import SpriteKit

@objcMembers

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player.png")
    var touchingPlayer : Bool = false
    var gameTimer : Timer?
    var nodeNum : Int = 0
    
    override func didMove(to view: SKView) {
        // scene ready to run, background
        let background = SKSpriteNode(imageNamed: "space.png")
        background.zPosition = -1 // below other nodes
        addChild(background)
        // space dust stuff
        if let particles = SKEmitterNode(fileNamed: "SpaceDust"){
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        // player stuff
        player.position.x = -300
        player.zPosition = 1
        addChild(player)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        let location = touch.location(in: self) // return loc inside scene
        let tappedNodes = nodes(at: location)// nodes precisely in that loc
        if tappedNodes.contains(player) {touchingPlayer = true}
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else {return}
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func createEnemy() {
        
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
        let angRotation : Double = Double.random(in: 0.5 ... 3.0)
        print(angRotation)
        asteroid.position = CGPoint(x: 320, y: Int.random(in: -260 ... 260))
        asteroid.name = "enemy"
        asteroid.zPosition = 1
        addChild(asteroid)
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        asteroid.physicsBody?.linearDamping = 0
        // asteroid rotation
        let oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: angRotation)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
    }
    
}
