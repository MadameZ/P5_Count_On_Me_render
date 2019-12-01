//
//  CountOnMeTests.swift
//  CountOnMeTests
//
//  Created by Caroline Zaini on 09/10/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
/// tests and the application are in differents targets so we have to import the module of our application.
//


import XCTest
@testable import CountOnMe

class CountOnMeTests: XCTestCase {
    // MARK: - Properties.
    var calculator : Calculator!
    
    // MARK: - Setup.
    override func setUp() {
    /// to prepare an instance which is reinitialized, then test are independant.
        super.setUp()
        calculator = Calculator()
    }
    
    func setElements(_ expression: String) {
        calculator.getElement = expression
    }
    
// MARK: - Test add a number.
/// test the starter.
    func testGivenGetElementIsZero_WhenAddNumber_ThenElementsReturnEmpty() {
       setElements("0")
       calculator.addNumber("3")
       XCTAssertEqual(calculator.elements, ["3"])
    }
/// add a number after an operation.
    func testGivenGetElementshavearesult_WhenAddNumber_ThenElementsReturnOneNumber() {
        setElements("2 + 2 = 4")
        calculator.addNumber("3")
        XCTAssertEqual(calculator.elements, ["3"])
    }
    
// MARK: - Test simple operations
/// test a simple addition.
    func testGivenOnePlusOne_WhentappedEqual_ThenResultIsTwo() {
        setElements("1")
        calculator.addOperator(.plus)
        calculator.addNumber("1")
        
        calculator.calcul()
        
        XCTAssert(calculator.canAddOperator)
        XCTAssert(calculator.expressionHaveResult)
        XCTAssert(calculator.expressionHaveEnoughElement)
        XCTAssertEqual(calculator.elements, ["1", "+", "1", "=", "2"])
     }
    
/// test a simple substraction.
    func testGivenTwoMinusTwo_WhentappedEqual_ThenResultIsZero() {
       setElements("2")
       calculator.addOperator(.minus)
       calculator.addNumber("2")
        
       calculator.calcul()
       
       XCTAssert(calculator.canAddOperator)
       XCTAssert(calculator.expressionHaveResult)
       XCTAssert(calculator.expressionHaveEnoughElement)
       XCTAssertEqual(calculator.elements, ["2", "-", "2", "=", "0"])
    }
    
 /// test a simple multiplication.
     func testGivenThreeMultiplyByThree_WhentappedEqual_ThenResultIsNine() {
         setElements("3")
         calculator.addOperator(.multiplication)
         calculator.addNumber("3")
        
         calculator.calcul()
         
         XCTAssert(calculator.canAddOperator)
         XCTAssert(calculator.expressionHaveResult)
         XCTAssert(calculator.expressionHaveEnoughElement)
         XCTAssertEqual(calculator.elements, ["3", "x", "3", "=", "9"])
      }
    
 /// test a simple division.
     func testGivenFourDivideByFour_WhentappedEqual_ThenResultIsOne() {
         setElements("4")
         calculator.addOperator(.division)
         calculator.addNumber("4")
        
         calculator.calcul()
         
         XCTAssert(calculator.canAddOperator)
         XCTAssert(calculator.expressionHaveResult)
         XCTAssert(calculator.expressionHaveEnoughElement)
         XCTAssertEqual(calculator.elements, ["4", "/", "4", "=", "1"])
      }
    
    // MARK: - Test operation with priority.
    func testGivenGetElementsContainOperationPriority_WhenCalculate_ThenPriorityOperatorsCalculFirst() {
        setElements("2 + 2 x 5 / 2")
        calculator.calcul()
        XCTAssertEqual(calculator.elements, ["2", "+", "2", "x", "5", "/", "2", "=", "7"] )
    }
    
    // MARK: - Test division by zero.
    func testGivenGetElementsContainDivisionByZero_WhenAddOPerator_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2 / 0")
        calculator.addOperator(.plus)
        
        XCTAssertEqual(calculator.elements, ["2", "/"])
        waitForExpectations(timeout: 0, handler: nil)
       }
    
    func testGivenGetElementsContainDivisionByZero_WhenCalculate_ThenSendANotification() {
        /// create an expectation
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2 / 0 = ")
        calculator.calcul()
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    // MARK: - Test error
/// Test - can't add an operator after another one.
    func testGivenGetElementsContainAnoperator_WhenAddAnOperator_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2 + ")
        calculator.addOperator(.plus)
        
        XCTAssertFalse(calculator.canAddOperator)
        waitForExpectations(timeout: 0.1, handler: nil)
      }
    
/// Test -  can't add a equal operator after another plus operator.
    func testGivenGetElementsContainanOperator_WhenAddOperator_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2 + ")
        calculator.calcul()
        
        XCTAssertFalse(calculator.expressionHaveEnoughElement)
        waitForExpectations(timeout: 0.1, handler: nil)
      }
    
/// Test - can't start calcul if expression hane not enough element
    func testGivenGetElementsContainTwoElements_WhenCalculate_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2")
        calculator.calcul()
        
        XCTAssertFalse(calculator.expressionHaveEnoughElement)
        waitForExpectations(timeout: 0.1, handler: nil)
      }

    /// Test can't add an equal after another equal.
    func testGivenGetElementsContainAnEqual_WhenCalculate_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("2 + 2 = ")
        calculator.calcul()

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    /// Test can't add an equal after another equal.
    func testGivenGetElementsContainZero_WhenAddOperator_ThenSendANotification() {
        expectation(forNotification: .showAlert, object: nil, handler: nil)
        setElements("0")
        calculator.addOperator(.plus)

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
/// test - can't add an unknowed operator.
   func testGivenGetElementsContainAnUnkowedOperator_WhenCalculate_ThenSendANotification() {
       expectation(forNotification: .showAlert, object: nil, handler: nil)
       setElements("2 i 2")
       calculator.calcul()

       XCTAssert(calculator.expressionHaveResult)
       waitForExpectations(timeout: 0.1, handler: nil)
   }
   
        // MARK: - Test decimal cases
    /// test add a zero before a decimal after an operator.
    func testGivenGetElementsHasANumber_WhenDecimalPointIsTapped_ThenAddTheDecimalPoint() {
      setElements("7")
      calculator.addDecimal()
      XCTAssertEqual(calculator.elements, ["7."])
    }
    
/// test can't add a decimal after an another point.
    func testGivenGetElementsHasOneDecimal_WhenDecimalIsTapped_ThenCantAddAnotherPoint() {
        setElements("2.")
        calculator.addDecimal()
        XCTAssertFalse(calculator.canAddDecimal)
    }
  
/// test can add a decimal after a number.
    func testGivenGetElementsHasDecimalPointAlone_WhenOperatorIsTapped_ThenRemoveThePoint() {
        setElements("5.")
        calculator.addOperator(.plus)
        XCTAssertEqual(calculator.elements, ["5", "+"])
    }
    
/// test add a zero before a decimal after an operator.
    func testGivenGetElementsHasAnOperator_WhenDecimalPointIsTapped_ThenAddAZeroBeforeThePoint() {
        setElements("5 + ")
        calculator.addDecimal()
        XCTAssertEqual(calculator.elements, ["5", "+", "0."])
    }
    

}
