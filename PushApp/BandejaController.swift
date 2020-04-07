//
//  BandejaController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

import SQLite

class BandejaController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var database: Connection!
    
    let usersTable = Table("bandeja")
    let id = Expression<Int>("id_bandeja")
    let titulo = Expression<String>("titulo_bandeja")
    let contenido = Expression<String>("contenido_bandeja")
    let fecha = Expression<String>("fecha_bandeja")
    let data = Expression<String>("data_bandeja")
    let imagen = Expression<String>("imagen_bandeja")
    let url = Expression<String>("url_bandeja")
    
    var bandejas: [Bandeja] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("bandeja").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        bandejas = createArray()
    }
    
    
    func createArray() -> [Bandeja]{
        
        var tempUsers: [Bandeja] = []
        
        do {
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                //print("userId: \(user[self.id]), name: \(user[self.name]), email: \(user[self.email])")
                let video = Bandeja(id: user[self.id],image: #imageLiteral(resourceName: "ico_push"), titulo: user[self.titulo],fecha:user[self.fecha],  contenido: user[self.contenido],data: user[self.data],urlimagen: user[self.imagen],url: user[self.url])
                
                /*print("Título: \(user[self.titulo])")
                print("Contenido: \(user[self.contenido])")
                print("Fecha: \(user[self.fecha])")
                print("Data: \(user[self.data])")
               print("Imagen: \(user[self.imagen])")
                print("Url: \(user[self.url])")
                    */
                
                
                tempUsers.append(video)
            }
            
            
        } catch {
            print(error)
        }
        
        return tempUsers
        
        
    }
    

    

   
}


extension BandejaController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bandejas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bandeja = bandejas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BandejaCell") as! BandejaCell
        cell.setBandeja(bandeja: bandeja)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetalleBandejaController") as? DetalleBandejaController
        let bandeja = bandejas[indexPath.row]
        vc?.fecha=bandeja.fecha
        vc?.titulo=bandeja.titulo
        vc?.contenido=bandeja.contenido
        vc?.imagenurl=bandeja.urlimagen
        vc?.data=bandeja.data
        vc?.url=bandeja.url
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at : indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
           
            
            let bandeja = self.bandejas[indexPath.row]
            
            
            let user = self.usersTable.filter(self.id == bandeja.id)
            let deleteUser = user.delete()
            do {
                try self.database.run(deleteUser)
            } catch {
                print(error)
            }
            
            
            
            
            self.bandejas.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            completion(true)
        }
        
        action.image=#imageLiteral(resourceName: "Trash")
        action.backgroundColor = .red
        
        
        
        
        return action
    }
    
}
