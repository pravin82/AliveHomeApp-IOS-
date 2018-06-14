//
//  ViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 06/05/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import Security
import Foundation
import UIKit
import Starscream
import RNCryptor
import SwiftyRSA

class ViewController: UIViewController,WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
        let  username = usernameText.text
        var  sharedAesKey=sharedKeyGenerator()
        let passwordtext=password.text
        let message1:String;
        let message2:String;
        let message3:String;
        let message4:String;
        message1="LOGI-"+username!
        message2="-"+passwordtext!
        message3="-"+sharedAesKey
        let pk = try? PublicKey(derNamed: "public_key")
        message4 = try!( encryption(message: message1+message2+message3,publicKey: pk! ))
        print("encrypted data :"+message4)
        socket.write(string: message4)
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print ("server got disconnected")
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print ("client received the message")
     let  decryptedMessage = try? decryptMessage(encryptedMessage: text, encryptionKey: sharedAesKey)
        print(decryptedMessage)
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print ("client recived the data")
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url:CFURL
        typealias SecTransformRef = CFTypeRef
       /* url = CFURLCreateFromFileSystemRepresentation (//yahaa error
            kCFAllocatorDefault,
            "public_key",
           12,
            false);
        let cfrs:CFReadStream
        cfrs = CFReadStreamCreateWithFile(
            kCFAllocatorDefault,
            url);
        let readTransform:SecTransformRef*/
        
       
        
       
        
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
    let importExportManager = CryptoExportImportManager()
  //  if  let publicKeyRef = importExportManager.importPublicKeyReferenceFromDERCertificate(certData) {
        // use publicKeyRef to sign, decrypt, etc..
  //  } else { ... handle error ... }
    
    
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
}

