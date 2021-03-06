//
//  SettingsViewController.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userIdLabel: UILabel!
    @IBOutlet var certificateFileName: UILabel!
    @IBOutlet var authorizeHealthDataLabel: UILabel!
    @IBOutlet var heartRateLabel: UILabel!
    @IBOutlet var awsEndpointIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeartRate(notification:)), name: .newHeartRateWatch, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameTextField.text = ConfigManager.userName()
        userIdLabel.text = ConfigManager.userId()
        certificateFileName.text = ConfigManager.certificateFileName()
        heartRateLabel.text = "--"
        awsEndpointIdTextField.text = ConfigManager.awsEndpointId()
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            ConfigManager.setUserName(userName: userNameTextField.text)
        } else if textField == awsEndpointIdTextField {
            ConfigManager.setAWSEndpointId(id: awsEndpointIdTextField.text ?? "")
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            //Authorize health data
            HealthDataManager.sharedInstance.requestAuthorization { (success) in
                DispatchQueue.main.async {
                    let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                    let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func updateHeartRate(notification:Notification) {
        if let heartRate = notification.object as? Double {
            DispatchQueue.main.async {
                self.heartRateLabel.text = String(format: "%.0f", heartRate)
            }
        }
    }
}
