//
//  ViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 06/05/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit
import Starscream
import RNCryptor

class ViewController: UIViewController,WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
        socket.write(string: message)
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print ("server got disconnected")
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print ("client received the message")
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print ("client recived the data")
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let  username = usernameText.text
        var  sharedAesKey=sharedKeyGenerator()
        let passwordtext=password.text
        let message1:String;
        let message2:String;
        let message3:String;
        message1="LOGI_"+username!
        message2="_"+passwordtext!
        message3="_"+sharedAesKey
        
        
        message = try?( encryptMessage(message: message1+message2+message3, encryptionKey:sharedAesKey ))
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var usernameText: UITextField!
    var socket:WebSocket!
    
    @IBOutlet weak var password: UITextField!
    @IBAction func logInButton(_ sender: UIButton) {
        logIntoServer()
        print("LogIn Button pressed")
    }
    @IBAction func registerButton(_ sender: UIButton) {
    }
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
    }
    var sharedAesKey:String!
   
    var message:String!
    
    func logIntoServer(){
        let  wsuri = "ws://alivehome.iitkgp.ac.in:81"
        socket = WebSocket(url: URL(string: wsuri)!)
        sharedAesKey=sharedKeyGenerator()
        socket.delegate=self
        socket.connect()
        socket.disconnect()
        
        
        
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
}

