//
//  EmpresasController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/15/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import SQLite
import Alamofire

class EmpresasController: UIViewController {
    
    var tokenInterno = ""
    var idEmpresa = 0

    // Create a global instance of NSUserDefaults class
    let defaults = UserDefaults.standard
    
    
 
    
    //SQL
    
    var database: Connection!
    
    let empresaTable = Table("empresa")
    let id_empresa = Expression<Int>("id_empresa")
    let id_tabla_empresa = Expression<Int>("id_tabla_empresa")
    let nombre_empresa = Expression<String>("nombre_empresa")
    let logo_empresa = Expression<String>("logo_empresa")
    
    
    @IBOutlet weak var tableView: UITableView!
    
     var empresas: [Empresa] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        //token interno
        tokenInterno = defaults.object(forKey: "tokenInterno") as? String ?? ""
        
        // SQL Empresa
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("empresa").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        //SQL Empresa
        
        let createTable = self.empresaTable.create { (table) in
            table.column(self.id_empresa, primaryKey: true)
            table.column(self.id_tabla_empresa)
            table.column(self.nombre_empresa)
            table.column(self.logo_empresa)
            
            
        }
        
        do {
            try self.database.run(createTable)
            print("Tabla Empresa Creada")
        } catch {
            print("Error al crear la tabla")
            print(error)
        }
        
        empresas = createArray()
    }
    
    func createArray() -> [Empresa]{
        
        var tempUsers: [Empresa] = []
        
        do {
            let users = try self.database.prepare(self.empresaTable)
            for user in users {
                //print("userId: \(user[self.id]), name: \(user[self.name]), email: \(user[self.email])")
                let video = Empresa(id:user[self.id_empresa] ,id_ext: user[self.id_tabla_empresa],nombre:user[self.nombre_empresa],  logo: user[self.logo_empresa])
               
                tempUsers.append(video)
            }
            
        } catch {
            print(error)
        }
        
        return tempUsers
        
    }
    
    
    
}

extension EmpresasController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return empresas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let empresa = empresas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmpresaCell") as! EmpresaCell
        cell.setEmpresa(empresa: empresa)
        
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    */
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at : indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, completion) in
            
            let empresa = self.empresas[indexPath.row]
            
            let parameters: Parameters = [
                
                "authHeader":self.tokenInterno,
                
                "idEmpresaDesvincular": empresa.id_externo
            ]
            
            let headers: HTTPHeaders = [
                
                "Authorization": "Bearer "+self.tokenInterno,
                "Content-Type": "application/json"
                
            ]
            
            
            AF.request("http://192.168.0.241:8080/api/movil/desvincularEmpresa",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")
                
                switch response.result {
                case let .success(value):
                    let json = value as AnyObject
                    
                    
                    print("JSon respuesta: ",json)
                    
                    guard let valor = json["respuesta"] as? String else { return }
                    //print("respuesta 2:",valor)
                    
                    if(valor == "true"){
                        print("Empresa:","Empresa desvinculada")
                        
                        
                        let user = self.empresaTable.filter(self.id_empresa == empresa.id)
                        let deleteUser = user.delete()
                        do {
                            try self.database.run(deleteUser)
                        } catch {
                            print(error)
                        }
                        
                        let alert = UIAlertController(title: "Empresa eliminada", message: "Ya no recibirá notificaciones de esta empresa", preferredStyle: .alert)
                        
                        
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else{
                        
                        print("Empresa:","Empresa no  desvinculada")
                        let alert = UIAlertController(title: "No se pudo borrar la empresa", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                        
                        
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        
                        
                    }
                    
                case let .failure(error):
                    
                    /* let alert = UIAlertController(title: "No se pudo borrar la empresa", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                     
                     
                     alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                     self.present(alert, animated: true)
                     */
                    break
                }
                
                
            }
            
            
            
            self.empresas.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        action.image=#imageLiteral(resourceName: "Trash")
        action.backgroundColor = .red
        
        
        
        
      
        
        return action
    }
    
    
}

