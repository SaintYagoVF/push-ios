//
//  MainVC.swift
//  PushApp
//
//  Created by Latinus Programador on 6/26/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class MainVC: UITabBarController{
    
    var tabBarIteam=UITabBarItem()
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray], for: .normal)
        
        let selectedImage1 = UIImage(named:"Alert_white")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named:"Alert_gray")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam=self.tabBar.items![0]
        tabBarIteam.image=deSelectedImage1
        tabBarIteam.selectedImage=selectedImage1
        
        let selectedImage2 = UIImage(named:"Add_white")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named:"Add_gray")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam=self.tabBar.items![1]
        tabBarIteam.image=deSelectedImage2
        tabBarIteam.selectedImage=selectedImage2
        
        let numberOfTabs = CGFloat((tabBar.items?.count)!)
        let tabBarSize = CGSize(width: tabBar.frame.width/numberOfTabs, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), size: tabBarSize)
        self.selectedIndex = 0
      
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(mostrarRegistro), name: NSNotification.Name("MostrarRegistro"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mostrarConfig), name: NSNotification.Name("MostrarConfig"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(mostrarEmpresas), name: NSNotification.Name("MostrarEmpresas"), object: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @objc func mostrarRegistro(){
        performSegue(withIdentifier: "MostrarRegistro", sender: nil)
        
    }
    
    @objc func mostrarConfig(){
        performSegue(withIdentifier: "MostrarConfig", sender: nil)
        
    }
    
    @objc func mostrarEmpresas(){
        performSegue(withIdentifier: "MostrarEmpresas", sender: nil)
        
    }

    @IBAction func onMoreTabbed(){
        print("TOGGLE SIDE MENU")
        
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
    }

}

extension UIImage{
    
    class func imageWithColor(color: UIColor,size: CGSize) -> UIImage{
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
