//
//  OfflineTableViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/08/01.
//

import UIKit

class OfflineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var aiArray = [
        "Charlie Puth",
        "Ed Sheeran",
        "Justin Bieber",
        "Selena Gomez",
        "Taylor Swift"
    ]
    
    let user = Player(
        name: LoginViewController.getUsername(),
        photo: SettingsViewController.getImage(),
        cards: (Card(), Card())
    )
    var playerArray: [Player] = []
    var playerCount = 1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gameStartButton: UIButton!
    @IBOutlet weak var addAIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        playerArray.append(user)
        
        addAIButton.layer.cornerRadius = 15
        addAIButton.layer.borderWidth = 2
        addAIButton.layer.borderColor = UIColor.black.cgColor
        
        gameStartButton.layer.cornerRadius = 15
        gameStartButton.layer.borderWidth = 2
        gameStartButton.layer.borderColor = UIColor.black.cgColor
        
        setUpMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpMode()
    }
    
    func setUpMode() {
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addAITableViewCell", for: indexPath) as! AddAITableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.aiLabel.font = UIFont(name: "Avenir", size: 16)
        cell.aiLabel.text = playerArray[row].name
        cell.userImage.image = playerArray[row].photo
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.tableView.backgroundColor = UIColor(hex: "#FFF8E1FF")
            cell.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.tableView.backgroundColor = UIColor(hex: "#283747FF")
            cell.backgroundColor = UIColor(hex: "#283747FF")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row != 0 {
                let temp = playerArray[indexPath.row].name
                aiArray.append(temp)
                
                playerArray.remove(at: indexPath.row)
                playerCount -= 1
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addAIButtonPressed(_ sender: Any) {
        
        if playerCount < 6 {
            let AI = AI(name: aiArray[0], photo: UIImage(named: "\(aiArray[0]).jpg")!, cards: (Card(), Card()))
            aiArray.remove(at: 0)
            playerCount += 1
            playerArray.append(AI)
            
        } else {
            let controller = UIAlertController(title: "Number of Players Restriction", message: "You can have up to 5 AIs", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
        
        tableView.reloadData()
    }
    
    @IBAction func gameStartButtonPressed(_ sender: Any) {
        if playerCount > 1 {
            performSegue(withIdentifier: "toGameSegueIdentifier", sender: self)
            
        } else {
            let controller = UIAlertController(title: "More Players Needed", message: "please add at lease 1 AI to start the game", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if playerArray.count <= 1{
            return
        }
        if segue.identifier == "toGameSegueIdentifier",
           let nextVC = segue.destination as? GameViewController {
            players = playerArray
        }
    }
    
}
