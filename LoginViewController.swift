//
//  LoginViewController.swift
//  HackUCI2018
//
//  Created by Andrew Vo on 2/3/18.
//  Copyright © 2018 Team Alabama. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        LoginButton.layer.masksToBounds = true
        LoginButton.layer.cornerRadius = 8
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField ==  emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
                    loginUser(email: email, password: password)
        }
    }
    
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("yay log in successful")
                self.performSegue(withIdentifier: "goToMainView", sender: self)
            }
        }
    }
}
