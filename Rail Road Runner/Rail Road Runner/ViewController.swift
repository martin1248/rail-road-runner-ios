//
//  ViewController.swift
//  Rail Road Runner
//
//  Created by martinhuch on 14.01.19.
//  Copyright © 2019 martin1248. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let userDefaultsTrainLength = "trainLength"

    @IBOutlet weak var trainLengthTextBox: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var remainingTrainLength: UILabel!
    @IBOutlet weak var startStopButton: UIButton!

    var locationManager : CLLocationManager!
    var started = false
    var startLocation : CLLocation?

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
        let currentLocation:CLLocation = locations[0] as CLLocation

        if started {
            if startLocation == nil {
                startLocation = currentLocation
            } else {
                let currentDistance : Int! = Int(startLocation!.distance(from: currentLocation))
                let expectedLength : Int! = Int(trainLengthTextBox.text!)
                var remainingLength = expectedLength  - currentDistance
                if remainingLength < 0 {
                    remainingLength = 0
                    started = false
                    trainLengthTextBox.isUserInteractionEnabled = true
                    startStopButton.setTitle("Start", for: UIControl.State.normal)
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    AudioServicesPlaySystemSound(1010)
                }
                remainingTrainLength.text = String(remainingLength)
            }
        } else {
            startLocation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location: " + error.localizedDescription)
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

