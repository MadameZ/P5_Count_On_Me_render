//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: -  Properties
    var calculator = Calculator()
    
    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet weak var clearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     /// notifications to receive informations from the model with observer, when controller is load in memory.
         NotificationCenter.default.addObserver(self, selector: #selector(display(notification:)), name: .updateDisplay, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(alert(notification:)), name:.showAlert, object: nil)
    }
}
// MARK: - Actions to handle Operation
extension ViewController {
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal) else { return }
            calculator.addNumber(numberText)
    }
/// simplify the Actions for the operators.
    @IBAction func tappedOperatorButton(_ sender: UIButton) {
        switch sender.tag {
            case 1: calculator.addOperator(.plus)
            case 2: calculator.addOperator(.minus)
            case 3: calculator.addOperator(.multiplication)
            case 4: calculator.addOperator(.division)
            default: return
        }
    }
/// new action for the decimal button.
    @IBAction func tappedDecimalButton(_ sender: UIButton) {
        calculator.addDecimal()
    }
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        calculator.calcul()
    }
    @IBAction func tappedResetButton(_ sender: UIButton) {
        calculator.reset()
    }
}
// MARK: - Methode's Notifications
extension ViewController {
      @objc func display(notification: Notification) {
          guard let userInfo = notification.userInfo else { return }
          textView.text = userInfo["input"] as? String
          TextViewDecrease()
          }
    
    @objc func alert(notification: Notification) {
        guard let userInfo = notification.userInfo else {  return }
    /// recupe the error messages to the user info.
        guard let error = userInfo["message"] as? String else { return }
        presentAlert(message: error)
    }
    
    private func TextViewDecrease() {
        if textView.text.count > 10 {
            textView.font = textView.font?.withSize(45)
        } else {
            textView.font = textView.font?.withSize(60)
        }
    }
}
// MARK: - Alert
extension ViewController {
    func presentAlert(message: String) {
        let alertVC = UIAlertController(title: "Zero !", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil ))
        present(alertVC, animated: true, completion: nil)
    }
}








