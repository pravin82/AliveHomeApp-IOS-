//
//  RegisterViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 06/05/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit
import Alamofire
import RNCryptor
import Starscream

class RegisterViewController: UIViewController,WebSocketDelegate {
    
    

    @IBOutlet weak var selectSecurityOutlet: UIButton!
    @IBOutlet var securityQuestionOutlet: [UIButton]!
    
    @IBOutlet weak var hardwareIdTextField: UITextField!
     var securityQuestionText:String!;
    
    @IBOutlet weak var providedUsernameTextField: UITextField!
    
    @IBOutlet weak var providedPasswordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var securityAnswerTextField: UITextField!
     var sharedAesKey:String!;
    var socket:WebSocket!;
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       securityQuestionOutlet.forEach { (securityQuestion) in
           securityQuestion.isHidden=true
        
        }
        // Do any additional setup after loading the view.
     
       sharedAesKey=sharedKeyGenerator()
      
        
        
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
        
        if isValidEmail(testStr: emailId!) && isValidUsername(Input: username!) && isValidSecurityAnswer(Input: securityAnswer!) && isValidPassword(Input: password!) && password==confirmPassword {
            let message1:String;
            let message2:String;
            let message3:String;
            let message4:String;
            let message5:String;
            let message6:String;
            let message7:String;
            let message:String;
            
            message1 = "NUS-" + hardwareId! + "-" + providedUsername! + "-"
                
            message2=providedPassword! + "-"
            message3=username! + "-" + password! + "-"
            message4=confirmPassword! + "-"+securityQuestionText
            message5="-" + securityAnswer! + "-"
            message6=emailId! + "-" + sharedAesKey
            message=message1+message2+message3+message4+message5+message6
            do{ let encryptedMessage=try encryptMessage(message: message, encryptionKey: sharedAesKey)
                loginToServer(message: encryptedMessage)
            }
            catch{
                print("Unable to encrypt message")
            }
            
            
            
            print("Register button pressed")
            
            
            
        }
            
    }
     
        
    
//    Checking if emailId is valid
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
//    Username's lenght should be between 6 and 18 characters
    func isValidUsername(Input:String) -> Bool {
        let RegEx = "\\A\\w{6,18}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }
    func isValidSecurityAnswer(Input:String) -> Bool {
        let RegEx = "\\A\\w{3,}\\z"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }
//  Password should be of   Minimum 8 characters at least 1 Alphabet and 1 Special Character:
    func isValidPassword(Input:String) -> Bool{

        let RegEx="^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with:Input)
        
    }
   
   
    
    
    func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
    func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        
        return decryptedString
    }
    
    

    @IBAction func securityQuestionButton(_ sender: UIButton) {
        securityQuestionOutlet.forEach { (securityQuestion) in
            securityQuestion.isHidden=true
        }
        
        if sender.tag==2{
            selectSecurityOutlet.setTitle("What is your mother maiden name?", for: .normal)
            securityQuestionText="What is your mother maiden name?"
            
            
        }
        else if sender.tag==1{
            selectSecurityOutlet.setTitle("What is your pet name?", for: .normal)
            securityQuestionText="What is your pet name?"
        }
        else if sender.tag==3{
            selectSecurityOutlet.setTitle("What is your Grandfather's name?", for: .normal)
            securityQuestionText="What is your Grandfather's name?"
        }
    }
    
    func isConnectedToInternet() -> Bool{
        return NetworkReachabilityManager()!.isReachable
        
    }
    func loginToServer(message:String){
        
        print("login function called")
        let wsuri = "ws://alivehome.iitkgp.ac.in:81"
        socket = WebSocket(url: URL(string: wsuri)!)
        socket.delegate=self
        socket.connect()
        
        
        socket.disconnect()
        
    }

    
    
    //  Starscream function required to Implement.
    func websocketDidConnect(socket: WebSocketClient) {
       print ("websocket is connected")
        
        
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do{
          try  decryptMessage(encryptedMessage: text, encryptionKey:sharedAesKey )
        }
        catch{
            print ("Message was not decrypted  by the server")
        }
    }
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
    func sharedKeyGenerator() -> String {
        let randString = "abcdefghijklmnopqrstuvwxyz0123456789{}[],.!@#$%^&*()"
        let arrayRand=Array(randString);
        
        var temphcar:Character
        var stringBuilder=""
        for index in 1...12 {
            temphcar=arrayRand[Int(arc4random_uniform(52))]
            stringBuilder.append(temphcar)
        }
        
        return stringBuilder
        
        
        
        
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
