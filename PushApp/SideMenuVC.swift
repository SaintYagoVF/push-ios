//
//  SideMenuVC.swift
//  PushApp
//
//  Created by Latinus Programador on 6/26/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

class SideMenuVC: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        switch indexPath.row{
            
        case 0: NotificationCenter.default.post(name: NSNotification.Name("MostrarRegistro"), object: nil)
        case 1: NotificationCenter.default.post(name: NSNotification.Name("MostrarConfig"), object: nil)
        case 2: NotificationCenter.default.post(name: NSNotification.Name("MostrarEmpresas"), object: nil)
        default:break
            
        }
    }

}
