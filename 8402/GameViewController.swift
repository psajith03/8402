import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            // Create the GameScene
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Center the scene
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            // Present the scene
            view.presentScene(scene)
            
            // Show debug information (optional)
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

