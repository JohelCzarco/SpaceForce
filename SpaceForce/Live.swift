//
//  Live.swift
//  SpaceForce
//
//  Created by JohelCzarco on 6/25/19.
//  Copyright © 2019 JohelCzarco. All rights reserved.
//

import Foundation

class Live {
    var lives : Int
    
    init(lives : Int) {
        self.lives = lives
    }
    
    func beenHit(){
        lives -= 1
    }
}

let PlayerLives = Live(lives: 2)
