//
//  GuardadoController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/17/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit

import SQLite

class GuardadoController: UIViewController {
    
    
    // SQL Guardado
    
    var database: Connection!
    
    let guardadoTable = Table("guardado")
    let id_guardado = Expression<Int>("id_guardado")
    let titulo_guardado = Expression<String>("titulo_guardado")
    let contenido_guardado = Expression<String>("contenido_guardado")
    let fecha_guardado = Expression<String>("fecha_guardado")
    let data_guardado = Expression<String>("data_guardado")
    let imagen_guardado = Expression<String>("imagen_guardado")
    let url_guardado = Expression<String>("url_guardado")
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var guardados: [Guardado] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("guardado").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        guardados = createArray()
    }
    
    func createArray() -> [Guardado]{
        
        var tempUsers: [Guardado] = []
        
        do {
            let users = try self.database.prepare(self.guardadoTable)
            for user in users {
                //print("userId: \(user[self.id]), name: \(user[self.name]), email: \(user[self.email])")
                let video = Guardado(id:user[self.id_guardado] ,image: #imageLiteral(resourceName: "ico_push"), titulo: user[self.titulo_guardado],fecha:user[self.fecha_guardado],  contenido: user[self.contenido_guardado],data: user[self.data_guardado],urlimagen: user[self.imagen_guardado],url: user[self.url_guardado])
                
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


extension GuardadoController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guardados.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let guardado = guardados[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuardadoCell") as! GuardadoCell
        cell.setGuardado(guardado: guardado)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetalleGuardadoController") as? DetalleGuardadoController
        let guardado = guardados[indexPath.row]
        vc?.fecha=guardado.fecha
        vc?.titulo=guardado.titulo
        vc?.contenido=guardado.contenido
        vc?.imagenurl=guardado.urlimagen
        vc?.data=guardado.data
        vc?.url=guardado.url
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at : indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
            
            
            
            let guardado = self.guardados[indexPath.row]
            
            
            let user = self.guardadoTable.filter(self.id_guardado == guardado.id)
            let deleteUser = user.delete()
            do {
                try self.database.run(deleteUser)
            } catch {
                print(error)
            }
            
            self.guardados.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
       
            
            completion(true)
        }
        
        action.image=#imageLiteral(resourceName: "Trash")
        action.backgroundColor = .red
        
    
       
        
        return action
    }
    
    
}
