//
//  OfflineTableViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/08/01.
//

import UIKit

class OfflineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var aiArray = ["Charlie Puth", "Ed Sheeran", "Justin Bieber", "Selena Gomez", "Taylor Swift"]
    let user = Player(name: LoginViewController.getUsername(), photo: SettingsViewController.getImage(), cards: (Card(), Card()))
    var playerArray: [Player] = []
    var playerCount = 1
    
    @IBOutlet weak var gameStartButton: UIButton!
    @IBOutlet weak var addAIButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        playerArray.append(user)
        
        instructionLabel.numberOfLines = 2
        instructionLabel.text = """
                        (Settings: Your picture will be updated if you
                        go back and make an offline game again)
                        """
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playerArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addAITableViewCell", for: indexPath) as! AddAITableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.aiLabel.text = playerArray[row].name
        cell.userImage.image = playerArray[row].photo

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
            aiArray.remove(at: 0) //change the index to the last index? (increased efficiency? since elements will not get shifted that way
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
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame",
                   let nextVC = segue.destination as? GameViewController {
                   nextVC.players = playerArray
                }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
