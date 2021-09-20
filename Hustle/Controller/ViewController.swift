//
//  ViewController.swift
//  Hustle
//
//  Created by Doeun Kwon on 2021-09-18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tapLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapLabel.alpha = 0.0
        tapLabel.startBlink()
    }

    @IBAction func tapPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToMain", sender: self)
    }
    
}

// MARK: - UILabel

extension UILabel {

    func startBlink() {
        UIView.animate(withDuration: 1.0,
              delay:2.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 1 },
              completion: nil)
    }
    
}
