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
    
    let buttonClick = SKAction.playSoundFileNamed("button-pressed-sound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        okayBtn = childNode(withName: "okayButton") as? SKSpriteNode
        animateButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if okayBtn.contains(touchLocation) {
            let transition = SKTransition.fade(withDuration: 0.25)
            let scene = GameScene(fileNamed: "GameScene.sks")!
            
            //play button sound
            run(buttonClick)
            
            scene.size = self.size
        
            view?.presentScene(scene, transition: transition)
        }
    }
    
    //animation
    func animateButton() {
                let scaleOut = SKAction.scale(to: 0.4, duration: 0.5)
                let scaleIn = SKAction.scale(to: 0.5, duration: 0.5)
                let scaleSequence = SKAction.sequence([scaleOut, scaleIn])
                let loopAction = SKAction.repeatForever(scaleSequence)
                okayBtn.run(loopAction)
        }
}
