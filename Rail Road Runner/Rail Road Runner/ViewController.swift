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

enum ButtonState {
    case Start
    case Stop
    case Deaktiviert
}

enum StopReason {
    case finished
    case stoppedByUser
    case stoppedDueToInsufficientLocationService
}

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    let trainLengths = ["100", "150", "200", "250", "300", "350", "400", "450", "500", "550", "600", "650", "700", "750" , "800" , "850", "900", "950", "1000", "1050", "1100", "1150", "1200", "1250", "1300", "1350", "1400"]
    let userDefaultsTrainLength = "trainLength"

    @IBOutlet weak var trainLengthTextBox: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var remainingTrainLength: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!

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
            setButtonAndText(state: .Start, text: "")
        } else {
            setButtonAndText(state: .Deaktiviert, text: "Ortungsdienst ist deaktiviert")
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
                setButtonAndText(state: .Start, text: "")
            }
        } else {
            if started {
                stop(reason: StopReason.stoppedDueToInsufficientLocationService)
                setButtonAndText(state: .Deaktiviert, text: "Abbruch: Standortdaten sind zu ungenau")
            } else {
                setButtonAndText(state: .Deaktiviert, text: "Standortdaten sind zu ungenau")
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
            stop(reason: StopReason.stoppedDueToInsufficientLocationService)
            setButtonAndText(state: .Deaktiviert, text: "Abbruch: Standortdaten sind nicht mehr verfügar")
        } else {
            setButtonAndText(state: .Deaktiviert, text: "Standortdaten sind nicht verfügar")
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
            stop(reason: StopReason.stoppedByUser)
            setButtonAndText(state: .Start, text: "")
        } else {
            setButtonAndText(state: .Stop, text: "")
            start()
        }
    }

    func start() {
        started = true
        trainLengthTextBox.isUserInteractionEnabled = false
        UserDefaults.standard.set(trainLengthTextBox.text, forKey: userDefaultsTrainLength)
    }

    func stop(reason : StopReason) {
        started = false
        if reason == StopReason.finished {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlaySystemSound(1010)
        } else if reason == StopReason.stoppedDueToInsufficientLocationService {
            AudioServicesPlaySystemSound(1005)
        }
        reset()
    }

    func reset() {
        trainLengthTextBox.isUserInteractionEnabled = true
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
            stop(reason: StopReason.finished)
        }
    }

    func setButtonAndText(state: ButtonState, text: String) {
        if state == ButtonState.Deaktiviert {
            startStopButton.isEnabled = false
            startStopButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        } else {
            startStopButton.isEnabled = true
            startStopButton.backgroundColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.5)
        }
        startStopButton.setTitle("\(state)", for: UIControl.State.normal)

        infoLabel.text = text
    }
}

