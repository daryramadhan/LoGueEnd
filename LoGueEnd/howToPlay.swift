//
//  howToPlay.swift
//  LoGueEnd-ver2
//
//  Created by Dary Ramadhan on 25/05/23.
//

import SpriteKit
import GameplayKit

class howToPlay: SKScene {
    var okayBtn: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        okayBtn = childNode(withName: "okayButton") as? SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if okayBtn.contains(touchLocation) {
            let transition = SKTransition.fade(withDuration: 0.25)
            let scene = GameScene(fileNamed: "GameScene.sks")!
            scene.size = self.size
        
            view?.presentScene(scene, transition: transition)
        }
    }
}
