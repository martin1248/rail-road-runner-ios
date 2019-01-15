//
//  ViewController.swift
//  Rail Road Runner
//
//  Created by martinhuch on 14.01.19.
//  Copyright © 2019 martin1248. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let userDefaultsTrainLength = "trainLength"

    @IBOutlet weak var trainLengthTextBox: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var gpsInaccurateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        startStopButton.layer.cornerRadius = 49
        startStopButton.clipsToBounds = true
        startStopButton.backgroundColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.5)

        if let trainLenght = UserDefaults.standard.string(forKey: userDefaultsTrainLength) {
            trainLengthTextBox.text = trainLenght;
        }

    }

    @IBAction func startStopWasPressed(_ sender: Any) {
        UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)
    }

}

