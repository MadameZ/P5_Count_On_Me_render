//
//  Caluculator.swift
//  CountOnMe
//
//  Created by Caroline Zaini on 25/09/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import Foundation

class Calculator {

    // MARK: - Enumerations
    enum Operator {
        case plus, minus, multiplication, division
    }
    
    // MARK: - Properties
    var getElement: String = "0" {
        didSet {
        /// when there's modifications in getElement, a notification is send to the controller to make an update.
            sendDisplayNotification(getElement)
        }
    }
   
    var elements : [String] {
    /// take the expression 'getElement' and separate the elements for being indexed in the array.
        return getElement.split(separator: " ").map { "\($0)" }
    }
    
    // MARK: - Properties
/// properties used before
    var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-" && elements.last != "x" && elements.last != "/"
    }
    var expressionHaveResult: Bool {
        return getElement.firstIndex(of: "=") != nil
    }
/// new property which detected the prirority calcul.
    private var isPriorityOperator: Bool {
        return elements.firstIndex(of: "x") != nil || elements.firstIndex(of: "/") != nil
    }
/// new property for decimal point, that verify if it not already contains a point.
     var canAddDecimal: Bool {
        if let elementLast = elements.last {
            if  elementLast.contains(".") {
                return false
            }
        }
        return true
    }
/// new property that verify if it not contains a division by zero.
    var expressionDivisionByZero: Bool {
        if getElement.contains("/ 0") {
            return false
        }
        return true
    }
    
    // MARK: - Methods to handle elements
    func addNumber(_ number: String) {
        starter()
        if !expressionHaveResult {
            getElement.append(number)
        } else {
       /// when the operation is finished then start a new one with a number.
            getElement = number
        }
    }
/// conditions of the first seizure of the calcul.
    private func starter() {
        if getElement.first == "0" {
            getElement = ""
        }
    }
    
/// to add an operator in the array with conditions.
    func addOperator(_ symbol: Operator) {
        if canAddOperator && !expressionHaveResult {
            decimalPointBeforeOperator()
            switch symbol {
                case .plus: handleDivisionZero(symbol: " + ")
                case .minus: handleDivisionZero(symbol: " - ")
                case .multiplication: handleDivisionZero(symbol: " x ")
                case .division: handleDivisionZero(symbol: " / ")
            }
        } else {
            sendMessageNotification(message: MessageError.alreadyHaveOperator)
        }
    }
    
/// case of decimal point alone before an operator.
    private func decimalPointBeforeOperator() {
        let position = getElement.index(getElement.endIndex, offsetBy: -1)
        let decimalPoint = getElement[position]
            if decimalPoint == "." {
                getElement.remove(at: position)
            }
    }
    
/// when operation contains division by zero, delete the zero after clicing on an operator.
    private func handleDivisionZero(symbol: String) {
        guard expressionDivisionByZero else {
            sendMessageNotification(message: MessageError.devideByZero)
            getElement.removeLast()
            return
        }
    /// when the operator is used at first.
        if getElement.first != "0" {
            getElement.append(symbol)
        } else {
            sendMessageNotification(message: MessageError.restart)
        }
    }

    func addDecimal() {
    /// don't take the zero at the begining.
        starter()
    /// when a decimal point is alone after an operator.
        if !canAddOperator {
            getElement.append("0.")
        } else if canAddDecimal && !expressionHaveResult {
            getElement.append(".")
        } else {
            sendMessageNotification(message: MessageError.cantAddDecimal)
        }
    }
    
    func reset() {
        getElement.removeAll()
        getElement = "0"
    }
}

// MARK: - The calcul
extension Calculator {
    
    func calcul() {
    /// verify with the guards if there are a problem, then send an error message.
        guard canAddOperator else { 
            return sendMessageNotification(message: MessageError.expressionNotCorrect)
        }
        guard expressionHaveEnoughElement else {
            return sendMessageNotification(message: MessageError.restart)
        }
        // new guard
        guard expressionDivisionByZero else {
            sendMessageNotification(message: MessageError.devideByZero)
            reset()
            return
        }
        if !expressionHaveResult {
            calculateTotal()
        } else {
            sendMessageNotification(message: MessageError.restart)
            reset()
        }
    }
    
   private func calculateTotal() {
    /// Create local copy of operations
        var operationsToReduce : [String] = []
        operationsToReduce = elements
            if isPriorityOperator {
                operationsToReduce = orderOfOperation(of: elements)
            }
    /// iterate operations while there's an element.
        while operationsToReduce.count > 1 {
        /// Take the three elements to make an operation.
            guard let left = Double(operationsToReduce[0]) else { return }
            let operand = operationsToReduce[1]
            guard let right = Double(operationsToReduce[2]) else { return }
            var result: Double
                switch operand {
                case "+": result = left + right
                case "-": result = left - right
                default:
                    sendMessageNotification(message: MessageError.unknowedOperator)
                    result = 0.0
                }
            /// delete the third elements of the array.
                operationsToReduce = Array(operationsToReduce.dropFirst(3))
            /// Insert the total at the begining of the array.
                operationsToReduce.insert("\(removeDotZero(result))", at: 0)
        }
    /// Recover the result and add in getElement.
        guard let result = operationsToReduce.first else { return }
        getElement.append(" = \(result)")
    }
    
    
    // new method
    private func orderOfOperation(of operation: [String]) -> [String] {
        var priorityOperation : [String] = operation
        while priorityOperation.contains("x") || priorityOperation.contains("/") {
            /// recupare an operator x or / and the index.
            if let i = priorityOperation.firstIndex(where: {$0 == "x" || $0 == "/"}) {
                let operand = priorityOperation[i]
                guard let left = Double(priorityOperation[i - 1]) else { return [] }
                guard let right = Double(priorityOperation[i + 1]) else { return [] }
                    var priorityResult: Double
                    if operand == "x" {
                        priorityResult = left * right
                    } else {
                        priorityResult = left / right
                    }
            /// replace the left number by the new result.
                priorityOperation[i - 1] = String(removeDotZero(priorityResult))
            /// delete the right number.
                priorityOperation.remove(at: i + 1)
            /// delete the operator.
                priorityOperation.remove(at: i)
            }
        }
        return priorityOperation
    }

/// remove the decimal point and the trailing zero.
    private func removeDotZero(_ result: Double) -> String {
        let doubleAsString : String = NumberFormatter.localizedString(from: NSNumber(value: result), number: .decimal)
        return doubleAsString
    }
}

// MARK: - Notifications
extension Calculator{
/// to post notifications to the controller.
    private func sendDisplayNotification(_ input : String) {
        NotificationCenter.default.post(name: .updateDisplay, object: nil, userInfo: ["input": input])
    }
    
    private func sendMessageNotification(message: String) {
        NotificationCenter.default.post(name: .showAlert, object: nil, userInfo: ["message": message])
    }
}

// MARK: - Notifications Name
extension Notification.Name {
/// notification's name use a static constant to be reuse and to not having string in code.
    static let updateDisplay = Notification.Name("updateDisplay")
    static let showAlert = Notification.Name("showAlert")
   
}

