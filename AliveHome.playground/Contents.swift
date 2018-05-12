//: Playground - noun: a place where people can play

import UIKit
import RNCryptor

var str = "Hello, playground"


func encryptMessage(message: String, encryptionKey: String) throws -> String {
    let messageData = message.data(using: .utf8)!
    let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
    print (cipherData.base64EncodedString())
    return cipherData.base64EncodedString()
}
func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
    
    let encryptedData = Data.init(base64Encoded: encryptedMessage)!
    let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
    let decryptedString = String(data: decryptedData, encoding: .utf8)!
    
    return decryptedString
}
//try encryptMessage(message: "pravin", encryptionKey: "abc")



