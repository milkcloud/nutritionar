//
//  ProfileViewController.swift
//  HackUCI2018
//
//  Created by Andrew Vo on 2/3/18.
//  Copyright © 2018 Team Alabama. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

class ProfileViewController: UIViewController {

    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var caloriesConsumedLabel: UILabel!
    @IBOutlet weak var remainingCaloriesLabel: UILabel!
    @IBOutlet weak var eatenFoodLabel: UILabel!
    var stringOfEatenFoods = ""
    var dailyCalorieGoal = 0
    var consumedCalories = 0
    var remainingCalories = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStringOfEatenFoods()
        setDailyCalorieGoal()
        setConsumedCalories()
        setRemainingCalories()
        // Do any additional setup after loading the view.
        
        eatenFoodLabel.layer.masksToBounds = true
        eatenFoodLabel.layer.cornerRadius = 10

    }
    
    func setStringOfEatenFoods() {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("EatenFood")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            self.stringOfEatenFoods = snapshotValue
            print(self.stringOfEatenFoods) //ACESS THE STRING WITH THIS
            //WRITE CODE IN HERE
            var myFoodArr = self.stringOfEatenFoods.split(separator: " ")
            var myFoodList = ""
            for foods in myFoodArr{
                myFoodList += " - " + foods.capitalized + "\n"
            }
            //WRITE IN HERE THIS IS IMPORTANT!!
            self.eatenFoodLabel.text = myFoodList
        }
    }
    
    func setDailyCalorieGoal() {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("TotalCalories")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Int
            self.dailyCalorieGoal = snapshotValue
            print(self.dailyCalorieGoal) //ACESS THE INT WITH THIS
            //WRITE CODE IN HERE
            self.totalCaloriesLabel.text = String(self.dailyCalorieGoal)
        }
    }
    
    func setConsumedCalories() {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("ConsumedCalories")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Int
            self.consumedCalories = snapshotValue
            print(self.consumedCalories) //ACESS THE INT WITH THIS
            //WRITE CODE IN HERE
            self.caloriesConsumedLabel.text = String(self.consumedCalories)
        }
    }
    
    func setRemainingCalories() {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("RemainingCalories")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Int
            self.remainingCalories = snapshotValue
            print(self.remainingCalories) //ACESS THE INT WITH THIS
            //WRITE CODE IN HERE
            self.remainingCaloriesLabel.text = String(self.remainingCalories)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func swipeUp(_ sender: Any) {
        performSegue(withIdentifier: "toCamera", sender: self)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
