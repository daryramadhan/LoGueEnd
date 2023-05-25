//
//  GameScene.swift
//  LoGueEnd-ver2
//
//  Created by Dary Ramadhan on 23/05/23.
//

import SpriteKit
import GameplayKit
import CoreHaptics

class GameScene: SKScene {
    
    //game sound
    let loseSound = SKAction.playSoundFileNamed("losing-sound-effect", waitForCompletion: false)
    let hitSound = SKAction.playSoundFileNamed("Single-clap-sound", waitForCompletion: false)
    
    //testing for label
    var labelNode: SKLabelNode!
    var modalNode: SKShapeNode!
    
    //modal
    var gameOverShape: SKShapeNode!
    var popUp: SKShapeNode!
    var gameoverLabel: SKLabelNode!
    var playAgain: SKShapeNode!
    
    let heartCount = 5
    
    var circle: SKSpriteNode!
    var handPlayer1: SKSpriteNode!
    var handPlayer2: SKSpriteNode!
    
    var bg1: SKSpriteNode!
    var bg2: SKSpriteNode!
    
    //Array for hearts
    var heartsPlayer1 = [SKSpriteNode] ()
    var heartsPlayer2 = [SKSpriteNode] ()
    var isTouchEnabled = true
    
    var timer: Timer?
    
    //Haptics
    var feedbackGenerator: CHHapticEngine?
    
    //Win or Lose
    var winPlayer1: SKSpriteNode!
    var winPlayer2: SKSpriteNode!
    var losePlayer1: SKSpriteNode!
    var losePlayer2: SKSpriteNode!
    
    //Self Attack
    var selfAttack: SKSpriteNode!

    var initialScreenPosition = CGPoint.zero
    
    override func didMove(to view: SKView) {
        
        initialScreenPosition = view.center
        
        // circle
        circle = childNode(withName: "circle") as? SKSpriteNode
        circle.color = .red
        
        startColorChangeTimer()
        
        // hand
        handPlayer1 = childNode(withName: "hand_1") as? SKSpriteNode
        handPlayer2 = childNode(withName: "hand_2") as? SKSpriteNode
        
        // background as touch area
        bg1 = childNode(withName: "bg_player1") as? SKSpriteNode
        bg2 = childNode(withName: "bg_player2") as? SKSpriteNode
        
        //self attack
        selfAttack = childNode(withName: "self_attack") as? SKSpriteNode
        selfAttack.isHidden = true
        
        //win or lose
        winPlayer1 = childNode(withName: "win_1") as? SKSpriteNode
        winPlayer1.isHidden = true
        
        winPlayer2 = childNode(withName: "win_2") as? SKSpriteNode
        winPlayer2.isHidden = true
        
        losePlayer1 = childNode(withName: "lose_1") as? SKSpriteNode
        losePlayer1.isHidden = true
        
        losePlayer2 = childNode(withName: "lose_2") as? SKSpriteNode
        losePlayer2.isHidden = true
        
        for i in 0..<heartCount {
            heartsPlayer1.append(childNode(withName: "heart1_\(i+1)") as! SKSpriteNode)
            heartsPlayer2.append(childNode(withName: "heart2_\(i+1)") as! SKSpriteNode)
        }
        
        
        //checking haptic condition
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                feedbackGenerator = try CHHapticEngine()
                try feedbackGenerator?.start()
            } catch {
                print("Haptic Engine Initialization Failed: \(error)")
            }
        }
        
    }
    
    func startColorChangeTimer() {
        let randomTimeInterval = TimeInterval.random(in: 1...5)
        timer = Timer.scheduledTimer(timeInterval: randomTimeInterval, target: self, selector: #selector(changeCircleColor), userInfo: nil, repeats: false)
    }
    
    @objc func changeCircleColor() {
        circle.color = .green
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if playAgain?.contains(touchLocation) == true {
            resetGame()
        }
        
        if isTouchEnabled {
            if bg1.contains(touchLocation) {
                player1()
            }
            else if bg2.contains(touchLocation) {
                player2()
            }
        }
    }
    
    // Reveal Visual Effect
    @objc func revealHit() {
            let fadeAction = SKAction.fadeIn(withDuration: 1)
            let waitAction = SKAction.wait(forDuration: 0.2)
            let fadeActionOut = SKAction.fadeOut(withDuration: 1)
            let showAction = SKAction.group([fadeAction, waitAction, fadeActionOut])
            
            selfAttack.alpha = 10
            selfAttack.isHidden = false
            selfAttack.setScale(1)
            
            selfAttack.run(showAction)
        }
    
    // Vibrate Screen
    func vibrateScreen() {
        let delay: TimeInterval = 0.2
        let duration = 0.1
        let amplitude: CGFloat = 10
        
        let originalPosition = view?.center
        
        let delayAction = SKAction.wait(forDuration: delay)
        
        self.run(delayAction) {
            // Shake the view horizontally using UIView animation
            UIView.animate(withDuration: duration, animations: {
                self.view?.center.y += amplitude
            }) { _ in
                UIView.animate(withDuration: duration, animations: {
                    self.view?.center.y -= amplitude * 2
                }) { _ in
                    UIView.animate(withDuration: duration, animations: {
                        self.view?.center.y += amplitude
                    }) { _ in
                        // Reset the view's position after the vibration
                        UIView.animate(withDuration: duration, animations: {
                            self.view?.center = originalPosition ?? CGPoint.zero
                        })
                    }
                }
            }
        }
    }
    
    
    // Player 1
    func player1() {
        let moveUpAction = SKAction.moveBy(x: 0, y: 350, duration: 0.1)
        let moveDownAction = SKAction.moveBy(x: 0, y: -350, duration: 0.1)
        let zoomInAction = SKAction.scale(to: 0.6, duration: 0.1)
        let zoomOutAction = SKAction.scale(to: 0.5, duration: 0.1)
        let sequenceAction = SKAction.sequence([zoomInAction, moveUpAction, moveDownAction, zoomOutAction])
        
        if circle.color == .green {
            disableTouchForOneSecond()
        }
        
        run(hitSound)
        
        handPlayer1.run(sequenceAction) {
            // Attack other player
            self.player1Attacked()
        }
        vibrateScreen()
        haptic()
        
    }
    
    func player1Attacked() {
        if circle.color == .green {
            //mengurangi heart lawan
            circle.color = .red
            startColorChangeTimer()
            if heartsPlayer2.count > 0 {
                heartsPlayer2.first?.isHidden = true
                heartsPlayer2.remove(at: 0)
                
                let handNum = 5-heartsPlayer2.count
                handPlayer2.texture = SKTexture(imageNamed: "hand\(handNum)")
            }
            if heartsPlayer2.count == 0 {
                gameEnd()
                player1Wins()
                
            }
        }
        else {
            //mengurangi heart kita
            if heartsPlayer1.count > 0 {
                heartsPlayer1.first?.isHidden = true
                heartsPlayer1.remove(at: 0)
                
                let handNum = 5-heartsPlayer1.count
                handPlayer1.texture = SKTexture(imageNamed: "hand\(handNum)")
            }
            if heartsPlayer1.count == 0 {
                gameEnd()
                player2Wins()
            }
            revealHit()
            
        }
    }
    
    // function for player 2
    func player2() {
        let moveUpAction = SKAction.moveBy(x: 0, y: -350, duration: 0.1)
        let moveDownAction = SKAction.moveBy(x: 0, y: 350, duration: 0.1)
        let zoomInAction = SKAction.scale(to: 0.6, duration: 0.1)
        let zoomOutAction = SKAction.scale(to: 0.5, duration: 0.1)
        let sequenceAction = SKAction.sequence([zoomInAction, moveUpAction, moveDownAction, zoomOutAction])
        
        if circle.color == .green {
            disableTouchForOneSecond()
        }
        run(hitSound)
        
        handPlayer2.run(sequenceAction) {
            // Attack other player
            self.player2Attacked()
        }
        vibrateScreen()
        haptic()
    }
    
    func player2Attacked() {
        if circle.color == .green {
            circle.color = .red
            startColorChangeTimer()
            //mengurangi heart lawan
            if heartsPlayer1.count > 0 {
                heartsPlayer1.first?.isHidden = true
                heartsPlayer1.remove(at: 0)
                
                let handNum = 5-heartsPlayer1.count
                handPlayer1.texture = SKTexture(imageNamed: "hand\(handNum)")
            }
            if heartsPlayer1.count == 0 {
                gameEnd()
                player2Wins()
            }
        }
        else {
            //mengurangi heart kita
            if heartsPlayer2.count > 0 {
                heartsPlayer2.first?.isHidden = true
                heartsPlayer2.remove(at: 0)
                
                let handNum = 5-heartsPlayer2.count
                handPlayer2.texture = SKTexture(imageNamed: "hand\(handNum)")
            }
            if heartsPlayer2.count == 0 {
                gameEnd()
                player1Wins()
            }
            revealHit()
            
        }
    }
    
    // Game Ended
    func gameEnd() {
        let delay: TimeInterval = 0.2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.heartsPlayer1.count == 0 || self.heartsPlayer2.count == 0 {
                self.showGameOverPopup()
                self.isTouchEnabled = false
            }
        }
        
        run(loseSound)
    }
    
    //show Game Over
    private func showGameOverPopup() {

        //Create background
        popUp = SKShapeNode(rectOf: CGSize(width: 265, height: 355), cornerRadius: 20)
        popUp.fillColor = .red
        popUp.strokeColor = .clear
        popUp.zPosition = 1
        popUp.setScale(0)
        
        //label
        gameoverLabel = SKLabelNode(text: "Game Over!")
        gameoverLabel.fontColor = .white
        gameoverLabel.fontSize = 35
        gameoverLabel.position = CGPoint(x: 0, y: 0)
        gameoverLabel.zPosition = 2
        
        playAgain = createButton(withText: "Play Again")
        playAgain.position = CGPoint(x: frame.midX, y: frame.midY)
        playAgain.zPosition = 5

        addChild(playAgain)
    }
    
    //Button
    func createButton(withText text: String) -> SKShapeNode {
        let buttonSize = CGSize(width: 157, height: 50)
        let cornerRadius: CGFloat = 20
        
        let button = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        button.fillColor = .white
        button.strokeColor = .clear
        
        let buttonLabel = SKLabelNode(text: text)
        buttonLabel.fontSize = 20
        buttonLabel.fontColor = .red
        buttonLabel.position = CGPoint(x: 0, y: 0)
        
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.verticalAlignmentMode = .center
        
        button.addChild(buttonLabel)
        
        return button
        
    }
    
    func createButton(rect: CGRect, cornerRadius: CGFloat, color: UIColor, action: @escaping () -> Void) -> SKShapeNode {
        playAgain = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        playAgain.fillColor = color
        playAgain.isUserInteractionEnabled = true

        return playAgain
    }
    
    //reset function
    func resetGame() {
        let transition = SKTransition.fade(withDuration: 0.25)
        let scene = GameScene(fileNamed: "GameScene.sks")!
        scene.size = self.size
        scene.scaleMode = self.scaleMode
        scene.position = self.position
        self.view?.center = initialScreenPosition
    
        view?.presentScene(scene, transition: transition)
    }
    
    //disable touch for one second
    func disableTouchForOneSecond() {
        isTouchEnabled = false

        let delayAction = SKAction.wait(forDuration: 0.1)
        self.run(delayAction) {
            self.isTouchEnabled = true
        }
    }
    
    @objc func player1Wins() {
            let fadeAction = SKAction.fadeIn(withDuration: 1)
            let showAction = SKAction.group([fadeAction])
            
            winPlayer1.alpha = 10
            winPlayer1.isHidden = false
            winPlayer1.zPosition = 10
        
            losePlayer2.alpha = 10
            losePlayer2.isHidden = false
            losePlayer2.zPosition = 10
            
            winPlayer1.run(showAction)
            losePlayer2.run(showAction)
        }
    
    @objc func player2Wins() {

            let fadeAction = SKAction.fadeIn(withDuration: 1)
            let showAction = SKAction.group([fadeAction])
            
            losePlayer1.alpha = 10
            losePlayer1.isHidden = false
            losePlayer1.zPosition = 10
        
            winPlayer2.alpha = 10
            winPlayer2.isHidden = false
            winPlayer2.zPosition = 10
            
            winPlayer2.run(showAction)
            losePlayer1.run(showAction)
        }
    
    func haptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}
