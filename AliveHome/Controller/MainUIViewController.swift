//
//  MainUIViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 16/06/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit
import Starscream
import CryptoSwift

var bulbState=""
class MainUIViewController: UIViewController,DevStateDelegate,WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
  
    let preferences = UserDefaults.standard
    let usernameKey = "username"
    let passwordKey = "password"
    let fanKey = "fan"
    let transKey = "trans"
    let sharedaesKey = "sharedaes"
    let socketKey="socket"
    var logInVC: ViewController!
    lazy var username = preferences.string(forKey: usernameKey)
    lazy var password = preferences.string(forKey: passwordKey)
    lazy var fanState = preferences.string(forKey: fanKey)
    lazy var transfer_session = preferences.string(forKey: transKey)
    lazy var sharedAesKey = preferences.string(forKey: sharedaesKey)
    
    
  
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        var array = [UInt8](repeating: 0x00, count: 16)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        let array1: [UInt8] = Array(sharedAesKey!.utf8)
        
        
        do {let partial1 = try digest.update(withBytes:array1 )
            let result=try digest.finish()
            let decryptedMessage1:String!
            decryptedMessage1 = try? text.aesDecrypt(key: result, iv: array)
            MainService().decryptedMessageHandler(decryptedMessage: decryptedMessage1,socket: socket)
            print("MainUIVC WS Message :"+decryptedMessage1)
            
        }
        catch{}
        
        
    }
 
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    //var socket:WebSocket!
    
    func changeBulb(state: String) {
        
        
        if state=="TL_ON"{
            
            button_light.setImage(#imageLiteral(resourceName: "bulb_on"), for: .normal)
            bulbState="TL_ON"
            
            
        }
        else{
            button_light.setImage(#imageLiteral(resourceName: "bulb_off"), for: .normal)
            bulbState="TL_OFF"
        }
    }
    
    @IBAction func button_light(_ sender: Any) {
      //  let  wsuri = "ws://alivehome.iitkgp.ac.in:81"
       // socket = WebSocket(url: URL(string: wsuri)!)
        //socket.connect()
        
        
        
        var array = [UInt8](repeating: 0x00, count: 16)
        let iv=array.toBase64()
        var digest = SHA2(variant: .sha256)
        
        let array1: [UInt8] = Array(sharedAesKey!.utf8)
        print("sharedAesKey Main UI :"+sharedAesKey! )
       
        if bulbState=="TL_ON"{
            bulbState="TL_OFF"
            button_light.setImage(#imageLiteral(resourceName: "bulb_off"), for: .normal)
            let str1="CTRL-" + username!
            let str2="-" + bulbState
            let str3="-" + fanState!
            let str4="-" + transfer_session!
            let str5=str1+str2+str3+str4
            do{
            let partial1 = try digest.update(withBytes:array1 )
            let result=try digest.finish()
                print ("str5  :"+str5)
              //  let sm1="sessionRequest-"+username!
             let esm1=try str5.aesEncrypt(key: result, iv: array)
                logInVC.socket.write(string: esm1)
            }
            catch{}
            
            }
        else{
            button_light.setImage(#imageLiteral(resourceName: "bulb_on"), for: .normal)
            bulbState = "TL_ON"
            let str1="CTRL-" + username!
            let str2="-" + bulbState
            let str3="-" + fanState!
            let str4="-" + transfer_session!
            let str5=str1+str2+str3+str4
            do{
                let partial1 = try digest.update(withBytes:array1 )
                let result=try digest.finish()
                print ("str5  :"+str5)
                //  let sm1="sessionRequest-"+username!
                let esm1=try str5.aesEncrypt(key: result, iv: array)
                logInVC.socket.write(string: esm1)
            }
            catch{}
        }
        
        
    }
    
    
    @IBOutlet weak var button_light: UIButton!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
        
    
     
    
            
            
        
    
    
 
    


}
