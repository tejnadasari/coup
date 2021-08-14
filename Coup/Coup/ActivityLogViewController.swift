//
//  GameLogViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/08/03.
//

import UIKit

class ActivityLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityLogLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var players: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moveLog.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityLogTableViewCell", for: indexPath) as! ActivityLogTableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.userProfile.image = moveLog[row].caller.photo
        cell.gameLogLabel.text = moveLog[row].toString()
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.tableView.backgroundColor = UIColor(hex: "#FFF8E1FF")
            cell.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.tableView.backgroundColor = UIColor(hex: "#283747FF")
            cell.backgroundColor = UIColor(hex: "#283747FF")
        }
        cell.textLabel?.numberOfLines = 3;
        
        return cell
    }
}
