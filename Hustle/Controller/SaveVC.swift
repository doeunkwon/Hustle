//
//  SaveVC.swift
//  Hustle
//
//  Created by Doeun Kwon on 2021-09-18.
//

import UIKit
import CoreData

class SaveVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var saveSlider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var freeLabel: UILabel!
    @IBOutlet weak var dayPercentageLabel: UILabel!
    
    var todayArray = [Today]()
    var savingsArray = [Savings]()
    var weeklySavingsArray = [WeeklySavings]()
    let shapeLayer = CAShapeLayer()
    var balance = Int32()
    
    var todaySpending = Int32(0)
    var todaySavings = Int32(0)
    var saveValue = 5
    var weeklySavings = Int32(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadToday()
        loadSavings()
        loadWeeklySavings()
        
        let hour = Calendar.current.component(.hour, from: Date())
        let hoursRemaining = Int32(24 - (hour + 1)) // hours remaining in the day (NOT the balance)
        
        // total hours spent on items today
        for item in todayArray {
            todaySpending += item.spend
        }
        
        // total hours saved today
        for hour in savingsArray {
            todaySavings += hour.hours
        }
        
        // balance = hoursRemaining - todaySpending - todaySavings // comment for test
        balance = 10 // uncomment for test
        
        // sets initial value for saving slider
        saveSlider.value = 5
        
        // aesthetics for confirmation button
        confirmButton.layer.cornerRadius = 20
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.layer.shadowRadius = 3.0
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        confirmButton.layer.shadowColor = UIColor.gray.cgColor
        
        // total hours saved in the past 7 days
        for hour in weeklySavingsArray {
            weeklySavings += hour.hours
        }
        freeLabel.text = "You've freed \(weeklySavings)h so far 🎉"
        dayPercentageLabel.text = "\((weeklySavings*100)/24)%"
        
        // progress circle to accompany the 'dayPercentageLabel'
        let center = CGPoint(x: 207, y: 657)
        let circularPath = UIBezierPath(arcCenter: center, radius: 130, startAngle: -CGFloat.pi / 2, endAngle: (2 * CGFloat.pi * CGFloat((Double(weeklySavings)/24.00))) - (CGFloat.pi / 2), clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(shapeLayer)
        
    }
    
    @IBAction func saveSlid(_ sender: UISlider) {
        saveValue = Int(sender.value)
        saveLabel.text = "You'll save \(saveValue)h 💫"
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        if balance - Int32(saveValue) >= 0 {
            let newEvent = Savings(context: context)
            newEvent.hours = Int32(saveValue)
            newEvent.origin = Date()
            let newWeeklyEvent = WeeklySavings(context: context)
            newWeeklyEvent.hours = Int32(saveValue)
            newWeeklyEvent.origin = Date()
            saveContext()
        } else {
            let alert = UIAlertController(title: "Insufficient Time", message: "You do not have enough time to save this much.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
            present(alert, animated: true)
        }
        saveContext()
    }
    
    // bundle to access CoreData
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    func loadToday() {
        let request : NSFetchRequest<Today> = Today.fetchRequest()
        do {
            todayArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    func loadSavings() {
        let request : NSFetchRequest<Savings> = Savings.fetchRequest()
        do {
            savingsArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    func loadWeeklySavings() {
        let request : NSFetchRequest<WeeklySavings> = WeeklySavings.fetchRequest()
        do {
            weeklySavingsArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

}
