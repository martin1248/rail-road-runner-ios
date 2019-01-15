//
//  ViewController.swift
//  Rail Road Runner
//
//  Created by martinhuch on 14.01.19.
//  Copyright © 2019 martin1248. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let userDefaultsTrainLength = "trainLength"
    let buttonColorDisabled = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
    let buttonColorEnabled = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.5)
    let minGpsAccuracy : Double = 50

    @IBOutlet weak var trainLengthTextBox: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var gpsAccuracyInfoLabel: UILabel!
    @IBOutlet weak var abortedInfoLabel: UILabel!

    var locationManager:CLLocationManager!
    var started = false

    var lastLocation : CLLocation?
    var currentDistance : CLLocationDistance?

    // MARK: - UIView

    override func viewDidLoad() {
        super.viewDidLoad()

        initLocationManager()
        locationManager.startUpdatingLocation()

        if let trainLenght = UserDefaults.standard.string(forKey: userDefaultsTrainLength) {
            trainLengthTextBox.text = trainLenght;
        }

        startStopButton.layer.cornerRadius = 49
        startStopButton.clipsToBounds = true
        startStopButton.backgroundColor = buttonColorDisabled
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManager

    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation

        let gpsAccurateEnough : Bool = userLocation.horizontalAccuracy > minGpsAccuracy

        if !gpsAccurateEnough {
            gpsAccuracyInfoLabel.text = "GPS Koordinaten sind zu ungenau."
            //startStopButton.backgroundColor = buttonColorDisabled
            startStopButton.isEnabled = false
        } else {
            gpsAccuracyInfoLabel.text = ""
            //startStopButton.backgroundColor = buttonColorEnabled
            startStopButton.isEnabled = true
        }
    }

    // MARK: - UI

    @IBAction func startStopWasPressed(_ sender: Any) {
        if !CLLocationManager.locationServicesEnabled() {
            gpsAccuracyInfoLabel.text = "GPS ist nicht aktiviert"
            return
        }

        if Int(trainLengthTextBox.text ?? "0") == 0 {
            return
        }
        UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)

    }

}

