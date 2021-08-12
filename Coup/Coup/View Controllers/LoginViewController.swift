//
//  LoginViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/20/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!

    
    let loginToCoupSegueIdentifier = "LoginToCoupSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmPasswordLabel.isHidden = true
        confirmPasswordTextField.isHidden = true
        
        loginButton.setTitle("Sign In", for: .normal)
        statusLabel.text = "Status"
        
        Auth.auth().addStateDidChangeListener() {
          auth, user in

          if user != nil {
            self.performSegue(withIdentifier: self.loginToCoupSegueIdentifier, sender: nil)
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
          }
        }
        
        segCtrl.layer.cornerRadius = 20.0
        let font = UIFont.systemFont(ofSize: 16)
        segCtrl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.black.cgColor
        
    }
    
    // MARK: - UI
    
    @IBAction func onSegmentChange(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex {
        case 0:
            // Sign In
            confirmPasswordLabel.isHidden = true
            confirmPasswordTextField.isHidden = true
            
            loginButton.setTitle("Sign In", for: .normal)
            statusLabel.text = "Status"
        case 1:
            // Sign Up
            confirmPasswordLabel.isHidden = false
            confirmPasswordTextField.isHidden = false
            
            loginButton.setTitle("Sign Up", for: .normal)
            statusLabel.text = "Status"
        default:
            print("This should never happen")
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if segCtrl.selectedSegmentIndex == 0 {
            signIn()
        } else if segCtrl.selectedSegmentIndex == 1 {
            signUp()
        }
    }
    
    // MARK: - Sign In and Up using Firebase
    
    func signIn() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email.count >= 7,
              password.count >= 7
        else {
            statusLabel.text = "Invalid Email or Password"
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let _ = error, user == nil {
                self.statusLabel.text = "Sign In Failed"
            } else {
                self.initializeSettingsInUserDefaults(email: email)
                self.performSegue(withIdentifier: self.loginToCoupSegueIdentifier, sender: nil)
            }
        }
    }
    
    func signUp() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              password == confirmPassword,
              email.count >= 7,
              password.count >= 7
        else {
            statusLabel.text = "Invalid Email or (Confirm) Password"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                self.signIn()
            } else {
                self.statusLabel.text = "Sign Up Failed"
            }
        }
    }
    
    // MARK: - User Defaults
    
    func storeEmailInUserDefaults(email: String) {
        let kEmailKey = "email"
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: kEmailKey)
    }
    
    static func getEmailInUserDefaults() -> String {
        let kEmailKey = "email"
        let defaults = UserDefaults.standard
        return defaults.object(forKey: kEmailKey) as! String
    }
    
    // use this function when fetching userName -> LoginViewController.getUsername()
    static func getUsername() -> String {
        let userEmail = getEmailInUserDefaults()
        var userName = ""
        
        if let rangeU = userEmail.range(of: "@") {
            userName = String(userEmail[..<rangeU.lowerBound])
        }
        
        return userName
    }
    
    static func storeModeInUserDefaults(mode: String) {
        let kModeKey = "mode"
        let defaults = UserDefaults.standard
        defaults.set(mode, forKey: kModeKey)
    }
    
    static func getModeInUserDefaults() -> String {
        let kModeKey = "mode"
        let defaults = UserDefaults.standard
        return defaults.object(forKey: kModeKey) as! String
    }
    
    static func storeEffectInUserDefaults(effect: String) {
        let kEffectKey = "effect"
        let defaults = UserDefaults.standard
        defaults.set(effect, forKey: kEffectKey)
    }
    
    static func getEffectInUserDefaults() -> String {
        let kEffectKey = "effect"
        let defaults = UserDefaults.standard
        return defaults.object(forKey: kEffectKey) as! String
    }
    
    func initializeSettingsInUserDefaults(email: String) {
        storeEmailInUserDefaults(email: email)
        LoginViewController.storeModeInUserDefaults(mode: "light")
        LoginViewController.storeEffectInUserDefaults(effect: "on")
    }
    
    // MARK: - Dismiss keyboard
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
