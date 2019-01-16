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

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    let trainLengths = ["100", "150", "200", "250", "300", "350", "400", "450", "500", "550", "600", "650", "700", "750" , "800" , "850", "900", "950", "1000"]
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

        let pickerView = UIPickerView()
        pickerView.delegate = self
        trainLengthTextBox.inputView = pickerView

        initLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            setButtonEnabled(enabled: false, disabledReason: "Ortungs Service ist nicht aktiviert")
        }

        if let trainLenght = UserDefaults.standard.string(forKey: userDefaultsTrainLength) {
            trainLengthTextBox.text = trainLenght;
        }

        startStopButton.layer.cornerRadius = 49
        startStopButton.clipsToBounds = true


        start(start: false)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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

        if currentLocation.horizontalAccuracy < 50 {
            setButtonEnabled(enabled: true, disabledReason: "")
        } else {
            if started {
                setButtonEnabled(enabled: false, disabledReason: "Abbruch: Koordinaten sind zu ungenau")
                start(start: false)
            } else {
                setButtonEnabled(enabled: false, disabledReason: "Koordinaten sind zu ungenau")
            }
        }

        if started {
            if startLocation == nil {
                startLocation = currentLocation
            } else {
                newLocationReceived(newLocation: currentLocation)
            }
        } else {
            startLocation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if started {
            setButtonEnabled(enabled: false, disabledReason: "Abbruch: Koordinaten sind nicht mehr verfügbar")
            start(start: false)
        } else {
            setButtonEnabled(enabled: false, disabledReason: "Koordinaten sind nicht verfügbar")
        }
    }

    // MARK: - Picker View

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return trainLengths.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return trainLengths[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        trainLengthTextBox.text = trainLengths[row]
    }

    // MARK: - Application logic

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func buttonWasPressed(_ sender: Any) {
         start(start: !started)
    }

    func start(start: Bool) {
        started = start
        trainLengthTextBox.isUserInteractionEnabled = start ? false : true
        startStopButton.setTitle(start ? "Stop" : "Start", for: UIControl.State.normal)

        if start {
            UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)
        } else {
            progressView.progress = 0
            remainingTrainLength.text = ""
        }
    }

    func newLocationReceived(newLocation : CLLocation) {
        let currentDistance : Int! = Int(startLocation!.distance(from: newLocation))
        let expectedLength : Int! = Int(trainLengthTextBox.text!)
        let remainingLength = expectedLength - currentDistance
        if remainingLength > 0 {
            let fractionalProgress : Float = Float(currentDistance) / Float(expectedLength);
            progressView.progress = fractionalProgress;
            remainingTrainLength.text = String(remainingLength)
        } else {
            start(start: false)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //AudioServicesPlaySystemSound(1010)
        }
    }

    func setButtonEnabled(enabled: Bool, disabledReason: String) {
        startStopButton.isEnabled = enabled
        if enabled {
            startStopButton.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.5)
        } else {
            startStopButton.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
        }
        print(disabledReason)
    }
}

