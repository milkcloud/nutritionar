//
//  ViewController.swift
//  HackUCI2018
//
//  Created by Andrew Vo on 2/2/18.
//  Copyright © 2018 Team Alabama. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Firebase

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var image : UIImage = UIImage()
    
    let model = Inceptionv3()
    
    var foodItem = ""
    var currentFoodNutrition = nutritionDataModel()
    var dailyValues = [String: Double]()
    var dailyPercentages = [String: Int]()
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @IBAction func tapGesturePressed(_ sender: UITapGestureRecognizer) {
        print("screen is pressed")
        
        //Remove all objects from screen
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
        
        //Get coordinates of location pressed
        let result = sceneView.hitTest(sender.location(in: nil), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
        let hitVector = SCNVector3Make(hitTransform.m41 + 0.05, hitTransform.m42, hitTransform.m43 - 0.05)
        
        takeScreenshot(position: hitVector)
        //        performSegue(withIdentifier: "test", sender: self)
    }
    
    @IBAction func swipeGestureSwiped(_ sender: UISwipeGestureRecognizer) {
        print("screen was swiped up")
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    func takeScreenshot(position: SCNVector3) {
        //var image = sceneView.snapshot()
        image = sceneView.snapshot()
        foodItem = classifyImage(image)
        currentFoodNutrition.processNutrition(food: foodItem)
        addFoodEaten(food: foodItem.replacingOccurrences(of: " ", with: ""))
        //self.updateConsumedUserCalories(calories: currentFoodNutrition.ca)

        setNutritionVariables(nutrition: currentFoodNutrition, position: position)
    }
    
    func addFoodEaten(food: String) {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("EatenFood")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! String
            let value = snapshotValue + "\(food) "
            userNEW.setValue(value)
        }
    }
    
    func setNutritionVariables(nutrition: nutritionDataModel, position: SCNVector3) {
        //DO ALL OPERATIONS IN THIS CLOSURE
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.dailyValues = self.currentFoodNutrition.getResults()
            self.dailyPercentages = self.currentFoodNutrition.getResultsPercentages()
            print(self.dailyValues)
            print(self.dailyPercentages)
            self.updateConsumedUserCalories(calories: Int(self.dailyValues["calories"]!))
            
            let foodtype = nutrition.name
            
            let cal = self.dailyValues["calories"]
            let fat = self.dailyValues["fat"]
            let sodium = self.dailyValues["sodium"]
            let carbs = self.dailyValues["carbs"]
            
            //Bar size varies based on a percentage
            let calper = Float(self.dailyPercentages["caloriesPercent"]!) / 100
            let fatper = Float(self.dailyPercentages["fatPercent"]!) / 100
            let sodper = Float(self.dailyPercentages["sodiumPercent"]!) / 100
            let carbsper = Float(self.dailyPercentages["carbsPercent"]!) / 100
            
            let calHeight = 0.1 * calper
            let fatHeight = 0.1 * fatper
            let sodiumHeight = 0.1 * sodper
            let carbsHeight = 0.1 * carbsper
            
            
            //food var
            let foodText = SCNText(string: String(format: "%@", foodtype), extrusionDepth: 1)
            
            //Bars vars
            let calorieBar = SCNBox(width: 0.01, height: CGFloat(calHeight), length: 0.01, chamferRadius: 0)
            let fatBar = SCNBox(width: 0.01, height: CGFloat(fatHeight), length: 0.01, chamferRadius: 0)
            let sodiumBar = SCNBox(width: 0.01, height: CGFloat(sodiumHeight), length: 0.01, chamferRadius: 0)
            let carbsBar = SCNBox(width: 0.01, height: CGFloat(carbsHeight), length: 0.01, chamferRadius: 0)
            
            //Text vars
            let calorieText = SCNText(string: "C\nA\nL\nO\nR\n I\nE\nS", extrusionDepth: 1)
            let fatText = SCNText(string: "F\nA\nT", extrusionDepth: 1)
            let sodiumText = SCNText(string: "S\nO\nD\n I\nU\nM", extrusionDepth: 1)
            let carbsText = SCNText(string: "C\nA\nR\nB\nS", extrusionDepth: 1)
            
            //Percentages vars
            let calp = SCNText(string: String(format: "%d\n%d%%", Int(cal!), Int(calper*100)), extrusionDepth: 1)
            let fatp = SCNText(string: String(format: "%d\n%d%%", Int(fat!), Int(fatper*100)), extrusionDepth: 1)
            let sodiump = SCNText(string: String(format: "%d\n%d%%", Int(sodium!), Int(sodper*100)), extrusionDepth: 1)
            let carbsp = SCNText(string: String(format: "%d\n%d%%", Int(carbs!), Int(carbsper*100)), extrusionDepth: 1)
            
            
            
            //assign color
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: CGFloat(121.0/255.0), green: CGFloat(207.0/255.0), blue: CGFloat(198.0/255.0), alpha: CGFloat(1.0))
            calorieBar.materials = [material]
            let material2 = SCNMaterial()
            material2.diffuse.contents = UIColor(red: CGFloat(122.0/255.0), green: CGFloat(162.0/255.0), blue: CGFloat(200.0/255.0), alpha: CGFloat(1.0))
            fatBar.materials = [material2]
            let material3 = SCNMaterial()
            material3.diffuse.contents = UIColor(red: CGFloat(144.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(207.0/255.0), alpha: CGFloat(1.0))
            sodiumBar.materials = [material3]
            let material4 = SCNMaterial()
            material4.diffuse.contents = UIColor(red: CGFloat(151.0/255.0), green: CGFloat(107.0/255.0), blue: CGFloat(202.0/255.0), alpha: CGFloat(1.0))
            carbsBar.materials = [material4]
            
            let material5 = SCNMaterial()
            material5.diffuse.contents = UIColor.white
            
            foodText.materials = [material5]
            
            calorieText.materials = [material5]
            fatText.materials = [material5]
            sodiumText.materials = [material5]
            carbsText.materials = [material5]
            
            calp.materials = [material5]
            fatp.materials = [material5]
            sodiump.materials = [material5]
            carbsp.materials = [material5]
            
            //Text Scaling
            //Food
            let bigtextscale = SCNVector3(x: 0.003, y: 0.003, z: 0.003)
            //Measures
            let textscale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
            //Percentages
            let textscale2 = SCNVector3(x: 0.0007, y: 0.0007, z: 0.0007)
            
            //Position
            let foodpos = SCNVector3Make(position.x - 0.015, position.y + 0.06, position.z)
            //bars
            let calpos = SCNVector3Make(position.x, position.y - (0.1 - calHeight)/2 ,position.z)
            let fatpos = SCNVector3Make(position.x + 0.03, position.y - (0.1 - fatHeight)/2, position.z)
            let sodiumpos = SCNVector3Make(position.x + 0.06, position.y - (0.1 - sodiumHeight)/2, position.z)
            let carbspos = SCNVector3Make(position.x + 0.09, position.y - (0.1 - carbsHeight)/2, position.z)
            //text
            let cal2pos = SCNVector3Make(position.x - 0.015, position.y - 0.05, position.z)
            let fat2pos = SCNVector3Make(fatpos.x - 0.015, position.y + 0.02, fatpos.z)
            let sodium2pos = SCNVector3Make(sodiumpos.x - 0.015, position.y - 0.022, sodiumpos.z)
            let carbs2pos = SCNVector3Make(carbspos.x - 0.015, position.y - 0.008, carbspos.z)
            //percentages
            let cal3pos = SCNVector3Make(calpos.x - 0.005, calpos.y + 0.5*calHeight, calpos.z)
            let fat3pos = SCNVector3Make(fatpos.x - 0.005, fatpos.y + 0.5*fatHeight, fatpos.z)
            let sodium3pos = SCNVector3Make(sodiumpos.x - 0.005, sodiumpos.y + 0.5*sodiumHeight, sodiumpos.z)
            let carbs3pos = SCNVector3Make(carbspos.x - 0.005, carbspos.y + 0.5*carbsHeight, carbspos.z)
            
            //Make bar a node to add into scene
            let calNode = SCNNode(geometry: calorieBar)
            calNode.position = calpos
            let fatNode = SCNNode(geometry: fatBar)
            fatNode.position = fatpos
            let sodiumNode = SCNNode(geometry: sodiumBar)
            sodiumNode.position = sodiumpos
            let carbsNode = SCNNode(geometry: carbsBar)
            carbsNode.position = carbspos
            
            //Make text nodes
            let foodNode = SCNNode(geometry: foodText)
            foodNode.position = foodpos
            foodNode.scale = bigtextscale
            
            let caltNode = SCNNode(geometry: calorieText)
            caltNode.position = cal2pos
            caltNode.scale = textscale
            let fattNode = SCNNode(geometry: fatText)
            fattNode.position = fat2pos
            fattNode.scale = textscale
            let sodiumtNode = SCNNode(geometry: sodiumText)
            sodiumtNode.position = sodium2pos
            sodiumtNode.scale = textscale
            let carbstNode = SCNNode(geometry: carbsText)
            carbstNode.position = carbs2pos
            carbstNode.scale = textscale
            
            let calpNode = SCNNode(geometry: calp)
            calpNode.position = cal3pos
            calpNode.scale = textscale2
            let fatpNode = SCNNode(geometry: fatp)
            fatpNode.position = fat3pos
            fatpNode.scale = textscale2
            let sodiumpNode = SCNNode(geometry: sodiump)
            sodiumpNode.position = sodium3pos
            sodiumpNode.scale = textscale2
            let carbspNode = SCNNode(geometry: carbsp)
            carbspNode.position = carbs3pos
            carbspNode.scale = textscale2
            
            
            
            
            //Add to scene, apply lighting
            self.sceneView.scene.rootNode.addChildNode(foodNode)
            
            self.sceneView.scene.rootNode.addChildNode(calNode)
            self.sceneView.scene.rootNode.addChildNode(fatNode)
            self.sceneView.scene.rootNode.addChildNode(sodiumNode)
            self.sceneView.scene.rootNode.addChildNode(carbsNode)
            
            self.sceneView.scene.rootNode.addChildNode(caltNode)
            self.sceneView.scene.rootNode.addChildNode(fattNode)
            self.sceneView.scene.rootNode.addChildNode(sodiumtNode)
            self.sceneView.scene.rootNode.addChildNode(carbstNode)
            
            self.sceneView.scene.rootNode.addChildNode(calpNode)
            self.sceneView.scene.rootNode.addChildNode(fatpNode)
            self.sceneView.scene.rootNode.addChildNode(sodiumpNode)
            self.sceneView.scene.rootNode.addChildNode(carbspNode)
            self.sceneView.autoenablesDefaultLighting = true
        })
    }
    
    //work on firebase
    func updateConsumedUserCalories(calories: Int) {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("ConsumedCalories")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Int
            let value = snapshotValue + calories
            userNEW.setValue(value)
            self.updateRemainingUserCalories(calories: calories)
        }
    }
    
    func updateRemainingUserCalories(calories: Int) {
        let usersDB = Database.database().reference().child("Users")
        guard let myUserID = Auth.auth().currentUser?.uid else {return}
        let userNEW = usersDB.child(myUserID).child("RemainingCalories")
        userNEW.observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as! Int
            let value = snapshotValue - calories
            userNEW.setValue(value)
        }
    }

    
    func classifyImage(_ image: UIImage) -> String{
        let size = CGSize(width: 299, height: 299)
        
        guard let pixelBufferImage = image.resize(to: size)?.pixelBuffer() else {
            fatalError("ERROR: Converting to pixel buffer failed!")
        }
        
        guard let inceptOutput = try? model.prediction(image: pixelBufferImage) else {
            fatalError("ERROR: Prediction failed")
            
        }
        
        let classOutput = inceptOutput.classLabel
        print(classOutput)
        return classOutput
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
