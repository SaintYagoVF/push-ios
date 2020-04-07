//
//  LauncherController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/18/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class LauncherController: UIViewController {
    
    // Create a global instance of NSUserDefaults class
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Reading from NSUserDefaults.
        
        let valorUsuario:String? = defaults.object(forKey: "tokenInterno") as? String
        //print("El usuario es = \(valorUsuario)")
        
        if(valorUsuario==nil){
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
            self.present(viewController, animated: false, completion: nil)
            
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
            self.present(viewController, animated: false, completion: nil)
           
            
            
        }
        
    }

  

}
