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
import CryptoSwift



class ViewController: UIViewController,WebSocketDelegate {
     lazy var sharedAesKey=sharedKeyGenerator()
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
        let  username = usernameText.text
       
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
        print (sharedAesKey)
        var array = [UInt8](repeating: 0x00, count: 16)
        let text1=text.base64Encoded()
        print("text: "+text)
        print("text1: "+text1!)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        
        let array1: [UInt8] = Array(sharedAesKey.utf8)
        do {let partial1 = try digest.update(withBytes:array1 )
            let result=try digest.finish()
            print("result \(result)")
            let decryptedMessage1:String!
             decryptedMessage1 = try? text.aesDecrypt(key: result, iv: array)
             print(decryptedMessage1) 
        }
        catch{}
        
        
    // let  decryptedMessage = try? decryptMessage(encryptedMessage: text, encryptionKey: sharedAesKey)
       
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print ("client recived the data")
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        var sharedAesKey:String!
         sharedAesKey=sharedKeyGenerator()
        // Do any additional setup after loading the view, typically from a n
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
    
   
    var message:String!
    
    
    
    func logIntoServer(){
       
        let  wsuri = "ws://alivehome.iitkgp.ac.in:81"
        socket = WebSocket(url: URL(string: wsuri)!)
       
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
        print ("In Decrypt Message function encryptedMessage:"+encryptedMessage)
        let decodedData = Data(base64Encoded: encryptedMessage, options: .ignoreUnknownCharacters)
        let dataString = String(data: decodedData!, encoding: String.Encoding.utf8)
        if let decodedData = decodedData {
            print("\(decodedData as NSData)")
        }

       // let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        do {
            let originalData = try RNCryptor.decrypt(data: decodedData!, withPassword: encryptionKey)
            return  String(data: originalData, encoding: String.Encoding.utf8)!
        } catch {
            print(error)
            return ("Data error")
        }
       // let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        //let decryptedString = String(data: decryptedData, encoding: .utf8)!
       
        
        
    }
    
}

