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
    @IBOutlet weak var locationServiceInfoLabel: UILabel!

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
            activateButton()
        } else {
            deactivateButton(reason: "Ortungs Service ist nicht aktiviert")
        }

        if let trainLenght = UserDefaults.standard.string(forKey: userDefaultsTrainLength) {
            trainLengthTextBox.text = trainLenght;
        }

        startStopButton.layer.cornerRadius = 49
        startStopButton.clipsToBounds = true

        reset()

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
            if !started {
                activateButton()
            }
        } else {
            if started {
                stop()
                deactivateButton(reason: "Abbruch: Ungenaue Koordinate")
                print("Ungenaue Koordinate: " + String(currentLocation.horizontalAccuracy))
            } else {
                deactivateButton(reason: "Ungenaue Koordinate")
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
            stop()
            deactivateButton(reason: "Abbruch: Koordinaten sind nicht verfügbar")
        } else {
            deactivateButton(reason: "Koordinaten sind nicht verfügbar")
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
        if started {
            stop()
        } else {
            start()
        }
    }

    func start() {
        print("start")
        started = true
        trainLengthTextBox.isUserInteractionEnabled = false
        startStopButton.setTitle("Stop", for: UIControl.State.normal)
        UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)
    }

    func stop() {
        print("stop")
        started = false
        reset()
    }

    func reset() {
        print("reset")
        trainLengthTextBox.isUserInteractionEnabled = true
        startStopButton.setTitle("Start", for: UIControl.State.normal)
        progressView.progress = 0
        remainingTrainLength.text = ""
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
            stop()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            //AudioServicesPlaySystemSound(1010)
        }
    }

    func activateButton() {
        print("activateButton")
        startStopButton.isEnabled = true
        startStopButton.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.5)
        startStopButton.setTitle("Start", for: UIControl.State.normal)
        locationServiceInfoLabel.text = ""
    }

    func deactivateButton(reason: String) {
        print("deactivateButton")
        startStopButton.isEnabled = false
        startStopButton.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
        startStopButton.setTitle("Deaktiviert", for: UIControl.State.normal)
        locationServiceInfoLabel.text = reason
    }
}

