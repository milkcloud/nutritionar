//
//  RegisterViewController.swift
//  HackUCI2018
//
//  Created by Andrew Vo on 2/2/18.
//  Copyright © 2018 Team Alabama. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var totalCaloriesTextField: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var SignUpButton: UIButton!
    var user = userDataModel()
    var gender = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SignUpButton.layer.masksToBounds = true
        SignUpButton.layer.cornerRadius = 8
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if let email = emailTextField.text {
            user.userEmail = email
        }
        if let password = passwordTextField.text {
            user.userPassword = password
        }
        registerNewUser(email: user.userEmail, password: user.userPassword)
    }
    
    func registerNewUser(email: String, password: String) {
        user.userEmail = email
        user.userGender = gender
        if let weight = weightTextField.text {
            user.userWeight = Int(weight)!
        }
        if let calories = totalCaloriesTextField.text {
            user.totalCalories = Int(calories)!
            user.remainingCalories = Int(calories)!
        }
        Auth.auth().createUser(withEmail: email, password: password) {
            (user, error) in
            if error != nil {
                print(error!)
            } else {
                //success
                print("registration successful!")
                self.loginUser(email: email, password: password)
            }
        }
    }
    
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("yay log in successful")
                self.configureNewUserDetails()
                self.performSegue(withIdentifier: "goToMainView", sender: self)
            }
        }
    }
    
    func configureNewUserDetails() {
        user.remainingCalories = user.totalCalories
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let usersInfo = usersDB.child(myUserID)
        
        let usersInfoDict = ["UserEmail" : user.userEmail, "UserGender" : user.userGender, "UserWeight" : user.userWeight, "TotalCalories" : user.totalCalories, "RemainingCalories" : user.remainingCalories, "ConsumedCalories" : user.consumedCalories, "EatenFood" : user.stringOfEatenFood] as [String : Any]
        
        usersInfo.setValue(usersInfoDict)
    }
    @IBAction func maleButtonPressed(_ sender: Any) {
        maleButton.setTitle("X", for: .normal)
        femaleButton.setTitle("", for: .normal)
        gender = "male"
    }
    @IBAction func femaleButtonPressed(_ sender: Any) {
        femaleButton.setTitle("X", for: .normal)
        maleButton.setTitle("", for: .normal)
        gender = "female"
    }
    
}
