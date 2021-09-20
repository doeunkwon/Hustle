//
//  SpendVC.swift
//  Hustle
//
//  Created by Doeun Kwon on 2021-09-18.
//

import UIKit
import CoreData

class SpendVC: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var eventTextfield: UITextField!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var spendSlider: UISlider!
    @IBOutlet weak var dailySwitch: UISwitch!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dailyTable: UITableView!
    @IBOutlet weak var dailySpendLabel: UILabel!
    
    var todayArray = [Today]()
    var dailyEvents = [Today]()
    var savingsArray = [Savings]()
    var balance = Int32()
    
    var spendValue = 4
    var todaySpending = Int32(0)
    var dailyValue = false
    var dailySpending = Int32(0)
    var todaySavings = Int32(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // uncomment above for path to Hustle.sqlite
        
        loadToday()
        loadSavings()
        
        eventTextfield.delegate = self
        
        dailyTable.delegate = self
        dailyTable.dataSource = self
        dailyTable.register(UINib(nibName: "RecordCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
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
        
        // sets initial values for the spending slider and daily switch
        spendSlider.value = 4
        dailySwitch.isOn = false
        
        // aesthetics for confirmation button
        confirmButton.layer.cornerRadius = 20
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.layer.shadowRadius = 3.0
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        confirmButton.layer.shadowColor = UIColor.gray.cgColor
        
        // makes a separate Array<Today> for daily items
        for item in todayArray {
            if item.daily {
                dailyEvents.append(item)
            }
        }
        
        // total hours spent on daily items
        for item in dailyEvents {
            dailySpending += item.spend
        }
        
        dailySpendLabel.text = "\(dailySpending)h"
        
    }
    
    @IBAction func spendSlid(_ sender: UISlider) {
        spendValue = Int(sender.value)
        spendLabel.text = "You'll spend \(spendValue)h ✨"
    }
    
    @IBAction func dailySwitched(_ sender: UISwitch) {
        if dailySwitch.isOn {
            dailyValue = true
        } else {
            dailyValue = false
        }
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        if let eventInput = eventTextfield.text {
            // checks to see that a text input is present
            if (eventInput != "") {
                // checks to see there is sufficient balance
                if balance - Int32(spendValue) >= 0 {
                    let newEvent = Today(context: context)
                    newEvent.event = eventInput
                    newEvent.spend = Int32(spendValue)
                    newEvent.daily = dailyValue
                    newEvent.origin = Date()
                    saveContext()
                } else {
                    let alert = UIAlertController(title: "Insufficient Time", message: "You do not have enough time for this event.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
                    present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "Invalid Input", message: "You should enter an event name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
                present(alert, animated: true)
            }
        }
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

}

// MARK: - UITextFieldDelegate

extension SpendVC: UITextFieldDelegate {
    
    // get rid keyboard when user taps elsewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        eventTextfield.endEditing(true)
    }
    
}

// MARK: - UITableViewDelegate

extension SpendVC: UITableViewDelegate {
    
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
                                       title: "Remove") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToDelete(tableView, indexPath)
                                        completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
}

// MARK: - UITableViewDataSource

extension SpendVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RecordCell
        cell.eventLabel.text = dailyEvents[indexPath.row].event
        if dailyEvents[indexPath.row].spend != 0 {
            cell.spendLabel.text = "\(dailyEvents[indexPath.row].spend)h"
        } else {
            cell.spendLabel.text = ""
        }
        cell.dailyLabel.text = ""
        return cell
    }
    
}
