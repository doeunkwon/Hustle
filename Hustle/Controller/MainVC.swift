//
//  MainVC.swift
//  Hustle
//
//  Created by Doeun Kwon on 2021-09-18.
//

import UIKit
import CoreData

class MainVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var spendButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var dayPercentageLabel: UILabel!
    @IBOutlet weak var weeklySavingsLabel: UILabel!
    @IBOutlet weak var todayTable: UITableView!
    @IBOutlet weak var totalSpendLabel: UILabel!
    
    var todayArray = [Today]()
    var nonDailyArray = [Today]()
    var savingsArray = [Savings]()
    var weeklySavingsArray = [WeeklySavings]()
    let shapeLayer = CAShapeLayer()
    
    var todaySavings = Int32(0)
    var weeklySavings = Int32(0)
    var todaySpending = Int32(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadToday()
        loadSavings()
        loadWeeklySavings()
        
        todayTable.delegate = self
        todayTable.dataSource = self
        todayTable.register(UINib(nibName: "RecordCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        for item in todayArray {
            if item.daily == false {
                nonDailyArray.append(item)
            }
        }
        
        let date = Date()
        
        var newDay = true
        
        // the following 'if' segments checks to see if either an item or saving was created from another day
        // if so, then the program deletes the data from the other day and initiates a clean canvas for a new day
        if nonDailyArray.count > 0 { // "if items already exist"
            if let originDate = nonDailyArray[0].origin { // arbitrarily picks 1st as test
                let originID = originDate.description.split(separator: " ")[0].split(separator: "-").joined() // converts Date() type into comparable date form regardless of time
                let todayID = date.description.split(separator: " ")[0].split(separator: "-").joined() // converts Date() type into comparable date form regardless of time
                if todayID > originID {
                    newDay = true
                } else {
                    newDay = false
                }
            }
        }
        if savingsArray.count > 0 { // "if savings already exist"
            if let originDate = savingsArray[0].origin { // arbitrarily picks 1st as test
                let originID = originDate.description.split(separator: " ")[0].split(separator: "-").joined() // converts Date() type into comparable date form regardless of time
                let todayID = date.description.split(separator: " ")[0].split(separator: "-").joined() // converts Date() type into comparable date form regardless of time
                if todayID > originID {
                    newDay = true
                } else {
                    newDay = false
                }
            }
        }
        
        // newDay = true // uncomment for testing
        
        // if today is a new day, then delete all the data from another day
        if newDay {
            for item in todayArray {
                if item.daily == false {
                    context.delete(item)
                }
            }
            for hour in savingsArray {
                context.delete(hour)
            }
            saveContext()
        }
        
        // aesthetics for save and spend buttons
        saveButton.layer.cornerRadius = 20
        saveButton.layer.shadowOpacity = 0.5
        saveButton.layer.shadowRadius = 3.0
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowColor = UIColor.gray.cgColor
        spendButton.layer.cornerRadius = 20
        spendButton.layer.shadowOpacity = 0.5
        spendButton.layer.shadowRadius = 3.0
        spendButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        spendButton.layer.shadowColor = UIColor.gray.cgColor
        
        let hour = Calendar.current.component(.hour, from: Date())
        let hoursRemaining = Int32(24 - (hour + 1)) // hours remaining in the day (NOT the balance)
        
        let minute = Calendar.current.component(.minute, from: Date())
        let minutesRemaining = Int32(60 - minute)
        
        // total hours spent on items today
        for item in todayArray {
            todaySpending += item.spend
        }
        
        // total hours saved today
        for hour in savingsArray {
            todaySavings += hour.hours
        }
        
        // total hours saved in the past 7 days
        for hour in weeklySavingsArray {
            weeklySavings += hour.hours
        }
        
        // let balance = hoursRemaining - todaySpending - todaySavings // comment for test
        let balance = 10 // uncomment for test
        
        // if the balance is negative (due to time leakage), then stop the balance at 0:00
        if balance >= 0 {
            if minutesRemaining < 10 {
                balanceLabel.text = "\(balance):0\(minutesRemaining)"
            } else {
                balanceLabel.text = "\(balance):\(minutesRemaining)"
            }
        } else {
            balanceLabel.text = "0:00"
        }
        
        // switches between lock/unlock emoji
        if todaySavings > 0 {
            savingsLabel.text = "🔒 \(todaySavings)h saved"
        } else {
            savingsLabel.text = "🔓 \(todaySavings)h saved"
        }
        
        dayPercentageLabel.text = "\((weeklySavings*100)/24)%"
        
        // progress circle to accompany the 'dayPercentageLabel'
        let center = CGPoint(x: 86, y: 298)
        let circularPath = UIBezierPath(arcCenter: center, radius: 25, startAngle: -CGFloat.pi / 2, endAngle: (2 * CGFloat.pi * CGFloat((Double(weeklySavings)/24.00))) - (CGFloat.pi / 2), clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(shapeLayer)
        
        // grammatical check
        if weeklySavings != 1 {
            weeklySavingsLabel.text = "You've freed \(weeklySavings) hours"
        } else {
            weeklySavingsLabel.text = "You've freed \(weeklySavings) hour"
        }
        
        totalSpendLabel.text = "\(todaySpending)h"
        
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

// MARK: - UITableViewDelegate

extension MainVC: UITableViewDelegate {
    
    // enables 'slide to delete' feature
    
    private func handleMoveToDelete(_ tableView: UITableView, _ indexPath: IndexPath) {
        context.delete(todayArray[indexPath.row])
        todayArray.remove(at: indexPath.row)
        saveContext()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive,
                                       title: "Refund") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToDelete(tableView, indexPath)
                                        completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
}

// MARK: - UITableViewDataSource

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RecordCell
        cell.eventLabel.text = todayArray[indexPath.row].event
        if todayArray[indexPath.row].spend != 0 {
            cell.spendLabel.text = "\(todayArray[indexPath.row].spend)h"
        } else {
            cell.spendLabel.text = ""
        }
        if todayArray[indexPath.row].daily == true {
            cell.dailyLabel.text = "Daily"
        } else {
            cell.dailyLabel.text = ""
        }
        return cell
    }
    
}

