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
    }
    
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
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
