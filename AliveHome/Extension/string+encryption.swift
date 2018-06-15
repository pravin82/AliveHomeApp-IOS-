//
//  string+encryption.swift
//  AliveHome
//
//  Created by Pravin Mishra on 14/06/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import Foundation

import CryptoSwift

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
        let parts = result1.components(separatedBy: "-")
        let bl = parts[0]=="NOTIFY"
        print(bl)
        return(parts[0])
    }
}
