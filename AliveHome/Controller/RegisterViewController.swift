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
import Security
import SwiftyRSA
import CryptoSwift
var hardwareId="";
var providedUsername="";
var providedPassword="";

var username="";
var emailId="";
var password="";
var confirmPassword="";
var securityAnswer="";

class RegisterViewController: UIViewController,WebSocketDelegate {
    
    
    
    lazy var  pk = try? PublicKey(derNamed: "public_key")
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
    var message:String!;
    
    
    
    
    
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
        hardwareId=hardwareIdTextField.text!;
         providedUsername=providedUsernameTextField.text!;
         providedPassword=providedPasswordTextField.text!;
       
         username=usernameTextField.text!;
         emailId=emailIdTextField.text!;
         password=passwordTextField.text!;
         confirmPassword=confirmPasswordTextField.text!;
         securityAnswer=securityAnswerTextField.text!;
        
        if isValidEmail(testStr: emailId) && isValidUsername(Input: username) && isValidSecurityAnswer(Input: securityAnswer) && isValidPassword(Input: password) && password==confirmPassword {
           
            do{
                loginToServer()
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
   
   
    
    
    func encryption(message:String,publicKey:PublicKey) throws ->String{
        
        let clear = try ClearMessage(string: message, using: .utf8)
        let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
        
        // Then you can use:
        
        let base64String = encrypted.base64String
        return base64String
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
    func loginToServer(){
        
        print("login function called")
        let wsuri = "ws://alivehome.iitkgp.ac.in:81"
        socket = WebSocket(url: URL(string: wsuri)!)
        socket.delegate=self
        socket.connect()
       
        
        
        socket.disconnect()
        
    }

    
    
    //  Starscream function required to Implement.
    func websocketDidConnect(socket: WebSocketClient) {
        let message1:String;
        let message2:String;
        let message3:String;
        let message4:String;
        let message5:String;
        let message6:String;
        let message7:String;
        
        
        message1 = "NUS-" + hardwareId + "-" + providedUsername + "-"
        
        message2=providedPassword + "-"
        message3=username + "-" + password + "-"
        message4=confirmPassword + "-"+securityQuestionText
        message5="-" + securityAnswer + "-"
        message6=emailId + "-" + sharedAesKey
        message=message1+message2+message3+message4+message5+message6
       print ("websocket is connected")
        if socket.isConnected{
            let encryptedMessage = try!( encryption(message: message,publicKey: pk! ))
            socket.write(string: encryptedMessage)
            print("Ready to write the message")
        }
        else{
            print("not ready to write the message")
        }
        
        
        
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        var array = [UInt8](repeating: 0x00, count: 16)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        let array1: [UInt8] = Array(sharedAesKey.utf8)
        
        
        do {let partial1 = try digest.update(withBytes:array1 )
            let result=try digest.finish()
            let decryptedMessage1:String!
            decryptedMessage1 = try? text.aesDecrypt(key: result, iv: array)
            decryptedMessageHandler(decryptedMessage: decryptedMessage1,socket: socket)
            print(decryptedMessage1)
        }
        catch{}
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
    func decryptedMessageHandler(decryptedMessage:String,socket:WebSocketClient){
        print("decrypted message handler called")
        var array = [UInt8](repeating: 0x00, count: 16)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        
        let array1: [UInt8] = Array(sharedAesKey.utf8)
        
        
        
        let parts = decryptedMessage.components(separatedBy: "-")
        if parts[0]=="NUS"{
            if parts[1]=="True"{
               // performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
                
                }
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
