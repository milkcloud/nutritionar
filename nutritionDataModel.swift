import Foundation
import Alamofire
import SwiftyJSON

class nutritionDataModel
{
    var parameters: [String: String]
    var headers: [String: String]
    var results: [String: Double]
    var percentages: [String: Int]
    var maxCalories: Double
    var maxFat: Double
    var maxSodium: Double
    var maxCarbs: Double


    var name: String
    
    init()
    {
        self.parameters = [String: String]()
        self.headers = [
            // Change these values when API key expires.

            "x-app-id": "6edee68a",
            "x-app-key": "2dcd03ed936284fdd76a563e022a128b"
        ]
        self.results = [String: Double]()
        self.percentages = [String: Int]()
        self.maxCalories = 2000.0
        self.maxFat = 65.0
        self.maxSodium = 2400.0
        self.maxCarbs = 300.0
        self.name = ""
    }
    
    func processNutrition(food: String)
    {
        self.parameters["query"] = food
        let baseURL = "https://trackapi.nutritionix.com/v2/natural/nutrients"
        
        self.name = food
        
        Alamofire.request(baseURL, method: .post, parameters: self.parameters, encoding: URLEncoding.default, headers: self.headers).responseJSON { (response) in
            
            if let value = response.result.value
            {
                var json = JSON(value)
                //print(value)
                let calories = (json["foods"][0]["nf_calories"]).doubleValue
                let fat = (json["foods"][0]["nf_total_fat"]).doubleValue
                let sodium = (json["foods"][0]["nf_sodium"]).doubleValue
                let carbs = (json["foods"][0]["nf_total_carbohydrate"]).doubleValue
                
                self.results["calories"] = round(calories)
                self.results["fat"] = Double(String(format: "%.1f", fat))
                self.results["sodium"] = Double(String(format: "%.1f", sodium))
                self.results["carbs"] = Double(String(format: "%.1f", carbs))
                
                self.percentages["caloriesPercent"] = Int(round((calories / self.maxCalories) * 100))
                self.percentages["fatPercent"] = Int(round((fat / self.maxFat) * 100))
                self.percentages["sodiumPercent"] = Int(round((sodium / self.maxSodium) * 100))
                self.percentages["carbsPercent"] = Int(round((carbs / self.maxCarbs) * 100))
            }
        }
    }
    
    func getResults() -> [String: Double]
    {
        return self.results
    }
    
    func getResultsPercentages() -> [String: Int]
    {
        return self.percentages
    }
}

// Use Nutrition class as shown:

//let foodInput = "hot dog"
//let currentFood = Nutrition()
//
//var dailyValues = [String: Double]()
//var dailyPercentages = [String: Int]()
//currentFood.processNutrition(food: foodInput)
//DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//    dailyValues = currentFood.getResults()
//    dailyPercentages = currentFood.getResultsPercentages()
//    print(dailyValues)
//    print(dailyPercentages)
//})

