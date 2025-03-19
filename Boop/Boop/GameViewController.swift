import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var feed: UILabel!
    var gkLabel: UILabel!
    var gcLabel: UILabel!
    var okLabel: UILabel!
    var ocLabel: UILabel!
    var feedCountObserver: NSKeyValueObservation!
    var gkObserver: NSKeyValueObservation!
    var gcObserver: NSKeyValueObservation!
    var okObserver: NSKeyValueObservation!
    var ocObserver: NSKeyValueObservation!
    var turnObserver: NSKeyValueObservation!
    let choiceType = UIButton(type: .system)
    
    let playAgain = UIButton(type: .system)
    var gameOverObserver: NSKeyValueObservation!
    var reset = false
    
    var undoObserver: NSKeyValueObservation!
    let undo = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the game scene
        if let view = self.view as! SKView? {
            scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
        
        //configure the scorerboard
        gkLabel = UILabel()
        gkLabel.frame = CGRect(x: 50, y: 240, width: 100, height: 100)
        gkLabel.textAlignment = .center
        gkLabel.font = UIFont.systemFont(ofSize: 45)
        gkLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        view.addSubview(gkLabel)
        
        gcLabel = UILabel()
        gcLabel.frame = CGRect(x: 190, y: 240, width: 100, height: 100)
        gcLabel.textAlignment = .center
        gcLabel.font = UIFont.systemFont(ofSize: 45)
        gcLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        view.addSubview(gcLabel)
        
        okLabel = UILabel()
        okLabel.frame = CGRect(x: 50, y: 155, width: 100, height: 100)
        okLabel.textAlignment = .center
        okLabel.font = UIFont.systemFont(ofSize: 45)
        okLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        view.addSubview(okLabel)
        
        ocLabel = UILabel()
        ocLabel.frame = CGRect(x: 190, y: 155, width: 100, height: 100)
        ocLabel.textAlignment = .center
        ocLabel.font = UIFont.systemFont(ofSize: 45)
        ocLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        view.addSubview(ocLabel)
        
        // configure the feed
        feed = UILabel()
        feed.frame = CGRect(x: 0, y: 800, width: 450, height: 50)
        feed.textAlignment = .center
        feed.font = UIFont.systemFont(ofSize: 18)
        feed.textColor = .white
        feed.numberOfLines = 0
        feed.lineBreakMode = .byWordWrapping
        feed.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feed)
        
        NSLayoutConstraint.activate([
            feed.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feed.topAnchor.constraint(equalTo: view.topAnchor, constant: 800),
            feed.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            feed.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // configure the choice type button
        updateButtonTitle()
        choiceType.addTarget(self, action: #selector(buttonChoiceTypeTapped), for: .touchUpInside)
        choiceType.center = view.center
        choiceType.backgroundColor = .white
        choiceType.layer.cornerRadius = 10
        choiceType.frame = CGRect(x: 352, y: 258, width: 75, height: 75)
        
        let buttonImage = UIImage(named: "Grey Kitten")?.withRenderingMode(.alwaysOriginal)
        choiceType.setImage(buttonImage, for: .normal)
        view.addSubview(choiceType)
        
        // configure the game over button
        playAgain.addTarget(self, action: #selector(buttonGameOverTapped), for: .touchUpInside)
        playAgain.center = view.center
        playAgain.backgroundColor = UIColor(red: 59/255, green: 161/255, blue: 217/255, alpha: 1.0)
        playAgain.layer.cornerRadius = 10
        playAgain.frame = CGRect(x: 157, y: 830, width: 125, height: 50)
        
        playAgain.setTitle("Play Again?", for: .normal)
        playAgain.setTitleColor(.white, for: .normal)
        playAgain.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        playAgain.isHidden = true  // Initially hidden
        view.addSubview(playAgain)
        
        // configure undo button
        updateUndo()
        undo.addTarget(self, action: #selector(buttonUndoTapped), for: .touchUpInside)
        undo.center = view.center
        undo.backgroundColor = .white
        undo.layer.cornerRadius = 10
        undo.frame = CGRect(x: 352, y: 175, width: 75, height: 75)
        
        let buttonUndoImage = UIImage(named: "undo.png")?.withRenderingMode(.alwaysOriginal)
        undo.setImage(buttonUndoImage, for: .normal)
        undo.isHidden = true  // Initially hidden
        view.addSubview(undo)
        
        // observe function calls
        observeGK()
        observeGC()
        observeOK()
        observeOC()
        observeFeed()
        observeTurn()
        observeGameOver()
        observeUndo()
    }
    
    @objc func buttonUndoTapped() {
        
        if (scene.gameOver) {
            playAgain.isHidden = true
        }
        
        scene.undoVars()
    }
    
    func updateUndo() {
        if scene.undoIsPossible {
            let buttonUndoImage = UIImage(named: "undo.png")?.withRenderingMode(.alwaysOriginal)
            undo.setImage(buttonUndoImage, for: .normal)
            undo.isHidden = false
        }
        else {
            undo.isHidden = true
        }
    }
    
    func observeUndo() {
        undoObserver = scene.observe(\.undoIsPossible, options: [.new, .old]) { [weak self] (undoIsPossible, change) in
            self?.updateUndo()
        }
        
        updateUndo()
    }
    
    @objc func buttonChoiceTypeTapped() {
        
        if scene.choice == 1 {
            scene.choice = 2
            print("Cats \(scene.choice)")
        }
        else if scene.choice == 2 {
            scene.choice = 1
            print("Kittens: \(scene.choice)")
        }
        
        updateButtonTitle()
    }

    func updateButtonTitle() {
        if scene.choice == 1 {
            if scene.turn == 0 {
                let buttonImage = UIImage(named: "Grey Kitten")?.withRenderingMode(.alwaysOriginal)
                choiceType.setImage(buttonImage, for: .normal)
            }
            else if scene.turn == 1 {
                let buttonImage = UIImage(named: "Orange Kitten")?.withRenderingMode(.alwaysOriginal)
                choiceType.setImage(buttonImage, for: .normal)
            }
        }
        else if scene.choice == 2 {
            if scene.turn == 0 {
                let buttonImage = UIImage(named: "Grey Cat")?.withRenderingMode(.alwaysOriginal)
                choiceType.setImage(buttonImage, for: .normal)
            }
            else if scene.turn == 1 {
                let buttonImage = UIImage(named: "Orange Cat")?.withRenderingMode(.alwaysOriginal)
                choiceType.setImage(buttonImage, for: .normal)
            }
        }
    }
    
    @objc func buttonGameOverTapped() {
        reset = true
        
        scene.reset()
        observeGK()
        observeGC()
        observeOK()
        observeOC()
        observeFeed()
        observeTurn()
        observeGameOver()
        scene.startFeed()
        
        reset = false
    }
    
    func observeGameOver() {
        
        gameOverObserver = scene.observe(\.gameOver, options: [.new, .old]) { [weak self] (gameOver, change) in
            self?.updateGameOverButton()
        }
        
        updateGameOverButton()
    }
    
    func updateGameOverButton() {
        if (scene.gameOver) {
            playAgain.isHidden = false
        }
        else if reset {
            playAgain.isHidden = true
        }
    }
    
    func observeTurn() {
        turnObserver = scene.observe(\.turn, options: [.new, .old]) { [weak self] (turn, change) in
            self?.updateButtonTitle()
        }
        
        updateButtonTitle()  // Initial label update
    }
    
    func observeGK() {
        
        if reset {
            gkObserver.invalidate()
        }
        
        gkObserver = scene.game.observe(\.gk, options: [.new, .old]) { [weak self] (gk, change) in
            self?.updateGK()
        }
        
        updateGK()  // Initial label update
    }
    
    func updateGK() {
        gkLabel.text = "\(scene.game.getGK())"
    }
    
    func observeGC() {
        
        if reset {
            gcObserver.invalidate()
        }
        
        gcObserver = scene.game.observe(\.gc, options: [.new, .old]) { [weak self] (gc, change) in
            self?.updateGC()
        }
        
        updateGC()  // Initial label update
    }
    
    func updateGC() {
        gcLabel.text = "\(scene.game.getGC())"
    }
    
    func observeOK() {
        
        if reset {
            okObserver.invalidate()
        }
        
        okObserver = scene.game.observe(\.ok, options: [.new, .old]) { [weak self] (ok, change) in
            self?.updateOK()
        }
        
        updateOK()  // Initial label update
    }
    
    func updateOK() {
        okLabel.text = "\(scene.game.getOK())"
    }
    
    func observeOC() {
        
        if reset {
            ocObserver.invalidate()
        }
        
        ocObserver = scene.game.observe(\.oc, options: [.new, .old]) { [weak self] (oc, change) in
            self?.updateOC()
        }
        
        updateOC()  // Initial label update
    }
    
    func updateOC() {
        ocLabel.text = "\(scene.game.getOC())"
    }
    
    func observeFeed() {
        
        if reset {
            feedCountObserver.invalidate()
        }
        
        feedCountObserver = scene.game.observe(\.feedCount, options: [.new, .old]) { [weak self] (feedCount, change) in
            self?.updateFeed()
        }
        
        updateFeed()  // Initial label update
    }
    
    func updateFeed() {
        feed.text = "\(scene.game.getFeed())"
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
