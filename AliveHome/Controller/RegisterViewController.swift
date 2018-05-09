//
//  RegisterViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 06/05/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var selectSecurityOutlet: UIButton!
    @IBOutlet var securityQuestionOutlet: [UIButton]!
    
    @IBOutlet weak var hardwareIdTextField: UITextField!
    
    @IBOutlet weak var providedUsernameTextField: UITextField!
    
    @IBOutlet weak var providedPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var securityAnswerTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       securityQuestionOutlet.forEach { (securityQuestion) in
           securityQuestion.isHidden=true
        }
        // Do any additional setup after loading the view.
     
        
    }
    
    
    
    @IBAction func selectSeurityButton(_ sender: UIButton) {
       securityQuestionOutlet.forEach { (securityQuestion) in
          securityQuestion.isHidden = !securityQuestion.isHidden
        }
    }
    @IBAction func registerButton(_ sender: UIButton) {
        let hardwareId=hardwareIdTextField.text;
        let providedUsername=providedUsernameTextField.text;
        let providedPassword=providedPasswordTextField.text;
        let username=usernameTextField.text;
        let emailId=emailIdTextField.text;
        let password=passwordTextField.text;
        let confirmPassword=confirmPasswordTextField.text;
        let securityAnswer=securityAnswerTextField.text;
        if   isValidUsername(Input: username!)
        {
            print("valid")
        }
        else{
            print("Invalid")
        }
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidUsername(Input:String) -> Bool {
        let RegEx = "\\A\\w{6,18}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }
   
    
    
   
    

    @IBAction func securityQuestionButton(_ sender: UIButton) {
        securityQuestionOutlet.forEach { (securityQuestion) in
            securityQuestion.isHidden=true
        }
        
        if sender.tag==2{
            selectSecurityOutlet.setTitle("What is your mother maiden name?", for: .normal)
            
        }
        else if sender.tag==1{
            selectSecurityOutlet.setTitle("What is your pet name?", for: .normal)
        }
        else if sender.tag==3{
            selectSecurityOutlet.setTitle("What is your Grandfather's name?", for: .normal)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
