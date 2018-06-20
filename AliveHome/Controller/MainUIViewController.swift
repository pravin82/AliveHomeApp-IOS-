//
//  MainUIViewController.swift
//  AliveHome
//
//  Created by Pravin Mishra on 16/06/18.
//  Copyright © 2018 Pravin Mishra. All rights reserved.
//

import UIKit


class MainUIViewController: UIViewController,DevStateDelegate {
    
    func changeBulb(state: String) {
        if state=="TL_ON"{
            button_light.setImage(#imageLiteral(resourceName: "bulb_on"), for: .normal)
        }
        else{
            button_light.setImage(#imageLiteral(resourceName: "bulb_off"), for: .normal)
        }
    }
    
    
    @IBOutlet weak var button_light: UIButton!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        let logVC=ViewController()
        logVC.delegate=self
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
        
    
     
    
            
            
        
    
    
 
    


}
