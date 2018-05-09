//
//  RegisterViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 06/05/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var selectSecurityOutlet: UIButton!
    @IBOutlet var securityQuestionOutlet: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
       securityQuestionOutlet.forEach { (securityQuestion) in
           securityQuestion.isHidden=true
        }
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func selectSeurityButton(_ sender: UIButton) {
       securityQuestionOutlet.forEach { (securityQuestion) in
          securityQuestion.isHidden = !securityQuestion.isHidden
        }
    }
    

    @IBAction func securityQuestionButton(_ sender: UIButton) {
        securityQuestionOutlet.forEach { (securityQuestion) in
            securityQuestion.isHidden=true
        }
        
        if sender.tag==2{
            selectSecurityOutlet.setTitle("What is your mother maiden name?", for: .normal)
            
        }
        else if sender.tag==1{
            selectSecurityOutlet.setTitle("What is your pet name?", for: .normal)
        }
        else if sender.tag==3{
            selectSecurityOutlet.setTitle("What is your Grandfather's name?", for: .normal)
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
