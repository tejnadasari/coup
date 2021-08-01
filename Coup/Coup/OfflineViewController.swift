//
//  OfflineTableViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/08/01.
//

import UIKit

var aiArray = ["Charlie Puth", "Ed Sheeran", "Justin Bieber", "Selena Gomez", "Taylor Swift"]
var playerArray: [Player] = []

class OfflineTableViewController: UITableViewController {

    let user = Player(name: "username", photo: UIImage(named: "Ariana Grande")!, cards: (Card(), Card()))
    var aiListCount = 0
    var playerCount = 1
    
    @IBOutlet weak var gameStartButton: UIButton!
    @IBOutlet weak var addAIButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        playerArray.append(user)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playerArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addAITableViewCell", for: indexPath) as! AddAITableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.aiLabel.text = playerArray[row].name
        cell.userImage = UIImageView(image: UIImage(named: cell.aiLabel.text!))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            playerArray.remove(at: indexPath.row)
            playerCount -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @IBAction func addAIButtonPressed(_ sender: Any) {
        
        if playerCount < 6 {
            let AI = Player(name: aiArray[aiListCount], photo: UIImage(named: aiArray[aiListCount])!, cards: (Card(), Card()))
            aiListCount = (aiListCount + 1) % 5
            playerCount += 1
            
            playerArray.append(AI)
            
        } else {
            let controller = UIAlertController(title: "The Max Number of Players Restriction", message: "You can have up to 5 AI players to play the game", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
            
        }
              
    }
    
    @IBAction func gameStartButtonPressed(_ sender: Any) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
