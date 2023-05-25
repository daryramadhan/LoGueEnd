//
//  MainMenu.swift
//  LoGueEnd-ver2
//
//  Created by Dary Ramadhan on 25/05/23.
//

import SpriteKit
import GameplayKit

class MainMenu: SKScene {
    var playBtn: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        playBtn = childNode(withName: "playButton") as? SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if playBtn.contains(touchLocation) {
            let transition = SKTransition.fade(withDuration: 0.25)
            let scene = howToPlay(fileNamed: "howToPlay.sks")!
            scene.size = self.size
        
            view?.presentScene(scene, transition: transition)
        }
    }
}
