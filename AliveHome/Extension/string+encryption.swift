//
//  string+encryption.swift
//  AliveHome
//
//  Created by Pravin Mishra on 14/06/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import Foundation

import CryptoSwift
import Security

extension String {
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    
    func aesDecrypt(key: Array<UInt8>, iv: Array<UInt8>) throws -> String {
        
       
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        let bytes = [UInt8](data!)
       print(bytes)
        let dec =  try AES(key: key, blockMode: .CBC(iv:iv), padding: .pkcs5).decrypt(bytes)
        print (dec)
        let decData = NSData(bytes: dec, length: Int(dec.count))
        print("dec Data:\(decData)")
        let result = NSString(data: decData as Data, encoding: String.Encoding.ascii.rawValue)
        
        
        let result1 = String(String(result!).dropFirst(16))
        
        
        return(result1)
    }
    func aesEncrypt(key:Array<UInt8>,iv:Array<UInt8>) throws ->String{
        let stringLength=self.count
        let val=(16-stringLength%16)
        let pString=Character(UnicodeScalar(val)!)
        let pString1=String(repeating: pString, count: 16)
        let paddedString=pString1+self
        print("length of paddedString:  \(paddedString.count)")
        let data=paddedString.data(using: .utf8)
        let bytes=[UInt8](data!)
        let enc=try AES(key:key,blockMode:.CBC(iv:iv),padding: .pkcs5).encrypt(bytes)
        let encryptedData = Data(enc)
        return encryptedData.base64EncodedString()
        
        
    }
   
}
