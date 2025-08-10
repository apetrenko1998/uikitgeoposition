//
//  BeaconDetectorViewController.swift
//  uikitgeoposition
//
//  Created by Anton Petrenko on 01/08/2025.
//

import UIKit
import CoreLocation

final class BeaconDetectorViewController: UIViewController {
    
    // MARK: - UI Elements
    private var uuidTextField: UITextField?
    private var majorTextField: UITextField?
    private var minorTextField: UITextField?
    private var startButton: UIButton?
    private var stopButton: UIButton?
    private var statusLabel: UILabel?
    private var resultsTextView: UITextView?
    
    private let locationManager = CLLocationManager()
    private var beaconRegion: CLBeaconRegion?
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        clearPreviousMonitoring()
        tabBarController?.tabBar.backgroundColor = .white
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let titleLabel = UILabel()
        titleLabel.text = "iBeacon Search"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let uuidTextField = UITextField()
        uuidTextField.borderStyle = .roundedRect
        uuidTextField.placeholder = "UUID (e.g., B9407F30-F5F8-466E-AFF9-25556B57FE6D)"
        uuidTextField.autocapitalizationType = .allCharacters
        uuidTextField.autocorrectionType = .no
        uuidTextField.translatesAutoresizingMaskIntoConstraints = false
        self.uuidTextField = uuidTextField
        
        let majorTextField = UITextField()
        majorTextField.borderStyle = .roundedRect
        majorTextField.placeholder = "Major (optional)"
        majorTextField.keyboardType = .numberPad
        majorTextField.translatesAutoresizingMaskIntoConstraints = false
        self.majorTextField = majorTextField
        
        let minorTextField = UITextField()
        minorTextField.borderStyle = .roundedRect
        minorTextField.placeholder = "Minor (optional)"
        minorTextField.keyboardType = .numberPad
        minorTextField.translatesAutoresizingMaskIntoConstraints = false
        self.minorTextField = minorTextField
        
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Searching", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        self.startButton = startButton
        
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop Searching", for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8
        stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        stopButton.isEnabled = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        self.stopButton = stopButton
        
        let statusLabel = UILabel()
        statusLabel.text = "Ready to search"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel = statusLabel
        
        let resultsTextView = UITextView()
        resultsTextView.isEditable = false
        resultsTextView.layer.borderWidth = 1
        resultsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        resultsTextView.layer.cornerRadius = 8
        resultsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        resultsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.resultsTextView = resultsTextView
        
        [titleLabel, uuidTextField, majorTextField, minorTextField,
         startButton, stopButton, statusLabel, resultsTextView].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            uuidTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            uuidTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uuidTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uuidTextField.heightAnchor.constraint(equalToConstant: 44),
            
            majorTextField.topAnchor.constraint(equalTo: uuidTextField.bottomAnchor, constant: 16),
            majorTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            majorTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            majorTextField.heightAnchor.constraint(equalToConstant: 44),
            
            minorTextField.topAnchor.constraint(equalTo: majorTextField.bottomAnchor, constant: 16),
            minorTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            minorTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            minorTextField.heightAnchor.constraint(equalToConstant: 44),
            
            startButton.topAnchor.constraint(equalTo: minorTextField.bottomAnchor, constant: 30),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4, constant: -25),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopButton.topAnchor.constraint(equalTo: minorTextField.bottomAnchor, constant: 30),
            stopButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stopButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4, constant: -25),
            stopButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultsTextView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            resultsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultsTextView.heightAnchor.constraint(equalToConstant: 300),
            resultsTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        handleAuthorizationStatus(locationManager.authorizationStatus)
    }
    
    private func clearPreviousMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
            
            if let beaconRegion = region as? CLBeaconRegion {
                if #available(iOS 13.0, *) {
                    locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
                } else {
                    locationManager.stopRangingBeacons(in: beaconRegion)
                }
            }
        }
        
        appendResult("🧹 Cleared \(locationManager.monitoredRegions.count) previous monitoring sessions")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard validateInputs() else { return }
        
        dismissKeyboard()
        createBeaconRegion()
        startBeaconDetection()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopBeaconDetection()
    }
    
    private func validateInputs() -> Bool {
        guard let uuidString = uuidTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !uuidString.isEmpty,
              UUID(uuidString: uuidString) != nil else {
            showAlert(title: "Invalid UUID", message: "Please enter a valid UUID")
            return false
        }
        
        // Validate major (optional)
        if let majorText = majorTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !majorText.isEmpty,
           Int(majorText) == nil || Int(majorText)! < 0 || Int(majorText)! > 65535 {
            showAlert(title: "Invalid Major", message: "Major must be a number between 0-65535")
            return false
        }
        
        // Validate minor (optional)
        if let minorText = minorTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !minorText.isEmpty,
           Int(minorText) == nil || Int(minorText)! < 0 || Int(minorText)! > 65535 {
            showAlert(title: "Invalid Minor", message: "Minor must be a number between 0-65535")
            return false
        }
        
        return true
    }
    
    private func createBeaconRegion() {
        guard let uuidString = uuidTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let uuid = UUID(uuidString: uuidString) else { return }
        
        let majorText = majorTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let minorText = minorTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let majorText = majorText, !majorText.isEmpty,
           let major = Int(majorText) {
            
            if let minorText = minorText, !minorText.isEmpty,
               let minor = Int(minorText) {
                // UUID + Major + Minor
                beaconRegion = CLBeaconRegion(
                    uuid: uuid,
                    major: CLBeaconMajorValue(major),
                    minor: CLBeaconMinorValue(minor),
                    identifier: "BeaconRegion_\(uuid.uuidString)_\(major)_\(minor)"
                )
            } else {
                // UUID + Major only
                beaconRegion = CLBeaconRegion(
                    uuid: uuid,
                    major: CLBeaconMajorValue(major),
                    identifier: "BeaconRegion_\(uuid.uuidString)_\(major)"
                )
            }
        } else {
            // UUID only
            beaconRegion = CLBeaconRegion(
                uuid: uuid,
                identifier: "BeaconRegion_\(uuid.uuidString)"
            )
        }
        
        beaconRegion?.notifyOnEntry = true
        beaconRegion?.notifyOnExit = true
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            updateStatus("Location authorized", color: .systemGreen)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            updateStatus("Requesting location permission...", color: .systemOrange)
        case .denied, .restricted:
            updateStatus("Location access denied", color: .systemRed)
            showAlert(title: "Location Required",
                     message: "Please enable location access in Settings to search for beacons")
        @unknown default:
            updateStatus("Unknown authorization status", color: .systemGray)
        }
    }
    
    private func startBeaconDetection() {
        guard let beaconRegion = beaconRegion else { return }
        
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else {
            updateStatus("Beacon monitoring not available", color: .systemRed)
            return
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            updateStatus("Location permission required", color: .systemRed)
            return
        }
        
        isSearching = true
        updateButtonStates()
        updateStatus("Searching for beacons...", color: .systemBlue)
        clearResults()
        
        locationManager.startMonitoring(for: beaconRegion)
        
        if CLLocationManager.isRangingAvailable() {
            if #available(iOS 13.0, *) {
                locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            } else {
                locationManager.startRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    private func stopBeaconDetection() {
        guard let beaconRegion = beaconRegion else { return }
        
        isSearching = false
        updateButtonStates()
        updateStatus("Search stopped", color: .systemGray)
        
        locationManager.stopMonitoring(for: beaconRegion)
        
        if #available(iOS 13.0, *) {
            locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        } else {
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
    }
    
    private func updateButtonStates() {
        startButton?.isEnabled = !isSearching
        stopButton?.isEnabled = isSearching
    }
    
    private func updateStatus(_ text: String, color: UIColor) {
        DispatchQueue.main.async {
            self.statusLabel?.text = text
            self.statusLabel?.textColor = color
        }
    }
    
    private func clearResults() {
        DispatchQueue.main.async {
            self.resultsTextView?.text = ""
        }
    }
    
    private func appendResult(_ text: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(),
                                                        dateStyle: .none,
                                                        timeStyle: .medium)
            let result = "[\(timestamp)] \(text)\n"
            self.resultsTextView?.text += result
            
            // Auto-scroll to bottom
            guard let resultsView = self.resultsTextView else { return }
            let bottom = NSMakeRange(resultsView.text.count - 1, 1)
            resultsView.scrollRangeToVisible(bottom)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension BeaconDetectorViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        appendResult("✅ Started monitoring for region: \(region.identifier)")
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        let stateString: String
        switch state {
        case .inside:
            stateString = "INSIDE"
        case .outside:
            stateString = "OUTSIDE"
        case .unknown:
            stateString = "UNKNOWN"
        }
        
        appendResult("📍 Region state: \(stateString)")
        
        if state == .inside, let beaconRegion = region as? CLBeaconRegion {
            if #available(iOS 13.0, *) {
                manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            } else {
                manager.startRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        appendResult("🟢 ENTERED region: \(region.identifier)")
        updateStatus("Beacon detected!", color: .systemGreen)
        
        if let beaconRegion = region as? CLBeaconRegion {
            if #available(iOS 13.0, *) {
                manager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
            } else {
                manager.startRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        appendResult("🔴 EXITED region: \(region.identifier)")
        updateStatus("Beacon lost", color: .systemOrange)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if !beacons.isEmpty {
            updateStatus("Found \(beacons.count) beacon(s)", color: .systemGreen)
        }
        
        for beacon in beacons {
            let proximityString: String
            switch beacon.proximity {
            case .immediate:
                proximityString = "IMMEDIATE"
            case .near:
                proximityString = "NEAR"
            case .far:
                proximityString = "FAR"
            case .unknown:
                proximityString = "UNKNOWN"
            @unknown default:
                proximityString = "UNKNOWN"
            }
            
            let accuracy = beacon.accuracy >= 0 ? String(format: "%.2fm", beacon.accuracy) : "Unknown"
            
            let beaconInfo = """
            📡 BEACON FOUND:
               UUID: \(beacon.uuid.uuidString)
               Major: \(beacon.major)
               Minor: \(beacon.minor)
               Proximity: \(proximityString)
               Accuracy: \(accuracy)
               RSSI: \(beacon.rssi) dBm
            """
            
            appendResult(beaconInfo)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        appendResult("❌ Location manager error: \(error.localizedDescription)")
        updateStatus("Error occurred", color: .systemRed)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        appendResult("❌ Ranging failed: \(error.localizedDescription)")
        updateStatus("Ranging failed", color: .systemRed)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        appendResult("❌ Monitoring failed: \(error.localizedDescription)")
        updateStatus("Monitoring failed", color: .systemRed)
    }
}
