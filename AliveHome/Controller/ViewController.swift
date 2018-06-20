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


let mySpecialNotificationKey = "specialNotificationKey"
protocol DevStateDelegate{
    func changeBulb(state:String)
}
class ViewController: UIViewController,WebSocketDelegate {
     lazy var sharedAesKey=sharedKeyGenerator()
     lazy var username=usernameText.text
     lazy var transfer_session=""
     lazy var  pk = try? PublicKey(derNamed: "public_key")
    
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket connected")
        let username=usernameText.text
       
        let passwordtext=password.text
        let message1:String;
        let message2:String;
        let message3:String;
        let message4:String;
        let message5:String;
        let message6:String;
        message1="LOGI-"+username!
        message2="-"+passwordtext!
        message3="-"+sharedAesKey
        message5="ENQ-"+username!+"-"+sharedAesKey
        message4 = try!( encryption(message: message1+message2+message3,publicKey: pk! ))
        message6=try!( encryption(message: message5,publicKey: pk! ))
        print("encrypted data :"+message4)
        socket.write(string: message4)
        socket.write(string: message6)
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print ("server got disconnected")
        
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
    
    var delegate:DevStateDelegate?
    
     
    @IBOutlet weak var password: UITextField!
    @IBAction func logInButton(_ sender: UIButton) {
        logIntoServer()
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
    func decryptedMessageHandler(decryptedMessage:String,socket:WebSocketClient){
        print("decrypted message handler called")
        var array = [UInt8](repeating: 0x00, count: 16)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        
        let array1: [UInt8] = Array(sharedAesKey.utf8)
        
        
        
        let parts = decryptedMessage.components(separatedBy: "-")
        if parts[0]=="VERIFY"{
            if parts[1]=="True"{
                if parts[2]=="STATUS"{
                    if parts[3]=="TL_ON"{
                        print("parts ==TL_ON")
                       // changeBulb(true)
                        print ("delegate :\(delegate)")
                        delegate?.changeBulb(state: parts[3])
                    }
                    else if parts[3]=="TL_OFF"{
                        delegate?.changeBulb(state: parts[3])
                        
                    }
                    
                }
                else if parts[2]=="BLEMAC"{
                    do {let partial1 = try digest.update(withBytes:array1 )
                        let result=try digest.finish()
                        let am1="ALARM-"+username!+"-status"
                        let eam1=try am1.aesEncrypt(key: result, iv: array)
                        let sm1="sessionRequest-"+username!
                        let esm1=try sm1.aesEncrypt(key: result, iv: array)
                        socket.write(string:eam1)
                        socket.write(string: esm1)
                       // let bssid = parts[3].substring(0, 17);
                        print("Alarm message send")
                       
                        
                    }
                    catch{}
                    
                  
                }
            }
        }
        else if parts[0]=="session"{
            transfer_session=parts[1]
            do {let partial1 = try digest.update(withBytes:array1 )
                let result=try digest.finish()
                
                socket.write(string:try ("STATUS-" + username! + "-" + transfer_session).aesEncrypt(key: result,iv:array))
                
            }
            catch{}
            
        }
        
        
    }
    func encryption(message:String,publicKey:PublicKey) throws ->String{
        
        let clear = try ClearMessage(string: message, using: .utf8)
        let encrypted = try clear.encrypted(with: publicKey, padding: .OAEP)
        
        // Then you can use:
        
        let base64String = encrypted.base64String
        return base64String
    }
    override   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="logInButtonSegue"{
            let sourceVC=segue.destination as! MainUIViewController
            self.delegate=sourceVC
            
            
        }
    }
    }
    
    
    
    


