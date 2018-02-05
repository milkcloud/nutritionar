//
//  HomeViewController.swift
//  HackUCI2018
//
//  Created by Andrew Vo on 2/3/18.
//  Copyright © 2018 Team Alabama. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var SignUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SignUpButton.layer.masksToBounds = true
        SignUpButton.layer.cornerRadius = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: self)
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
