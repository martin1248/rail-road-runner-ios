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
    let minGpsAccuracy : Double = 50

    @IBOutlet weak var trainLengthTextBox: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var gpsAccuracyInfoLabel: UILabel!
    @IBOutlet weak var abortedInfoLabel: UILabel!

    var updateTimer : Timer?
    var locationManager:CLLocationManager!
    var started = false

    var lastLocation : CLLocation?
    var currentDistance : CLLocationDistance?

    // MARK: - UIView

    override func viewDidLoad() {
        super.viewDidLoad()

        initLocationManager()
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let trainLenght = UserDefaults.standard.string(forKey: userDefaultsTrainLength) {
            trainLengthTextBox.text = trainLenght;
        }

        startStopButton.layer.cornerRadius = 49
        startStopButton.clipsToBounds = true
        startStopButton.isEnabled = true

        self.updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    @objc func update() {

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        updateTimer?.invalidate()
    }

    // MARK: - CLLocationManager

    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations[0] as CLLocation

        let gpsAccurateEnough : Bool = currentLocation.horizontalAccuracy > minGpsAccuracy

        if !gpsAccurateEnough {
            gpsAccuracyInfoLabel.text = "GPS Koordinaten sind zu ungenau."
            startStopButton.isEnabled = false
        } else {
            gpsAccuracyInfoLabel.text = ""
            startStopButton.isEnabled = true
        }

        if started {
            if lastLocation != nil {
                let lastDistance = lastLocation?.distance(from: currentLocation)

            }
            lastLocation = currentLocation
        } else {
            lastLocation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }

    // MARK: - UI

    @IBAction func startStopWasPressed(_ sender: Any) {
         if Int(trainLengthTextBox.text ?? "0") == 0 {
            return
        }

        if !started {
            started = true
            trainLengthTextBox.isUserInteractionEnabled = false
            UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)
            startStopButton.setTitle("Stop", for: UIControl.State.normal)
        } else {
            started = false
            trainLengthTextBox.isUserInteractionEnabled = true
            startStopButton.setTitle("Start", for: UIControl.State.normal)
        }
    }

}

