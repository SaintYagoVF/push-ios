//
//  LoginController.swift
//  PushApp
//
//  Created by Latinus Programador on 7/25/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import SQLite
import OneSignal
import AVFoundation
import Alamofire
import CoreLocation

class LoginController: UIViewController , CLLocationManagerDelegate {
    
    
    //SQL
    
    var database: Connection!
    
    let empresaTable = Table("empresa")
    let id_empresa = Expression<Int>("id_empresa")
    let id_tabla_empresa = Expression<Int>("id_tabla_empresa")
    let nombre_empresa = Expression<String>("nombre_empresa")
    let logo_empresa = Expression<String>("logo_empresa")
    
    
    //Variables
    let activityindicatorView = UIActivityIndicatorView(style: .whiteLarge)

    var emailLogin = ""
    var claveLogin = ""
    var tokenInterno = ""
    
    var iconClick = true

    //GPS
    
    
    var latitud : Double = 1
    
    var longitud : Double = 1
    
    
    let locMan : CLLocationManager = CLLocationManager()
    
    let headers3: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Basic MzA3NjEwYjUtZWZlYy00Njc5LWE2Y2UtYzQ5YjMwNDRhNTVj"
        
    ]
    
    let headers2: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
        
    ]
    
    
    var pushtoken : String = ""
    
    
    // Create a global instance of NSUserDefaults class
    let defaults = UserDefaults.standard

    
    @IBOutlet weak var txtEmail: UITextField!
    
    
    @IBOutlet weak var txtClave: UITextField!
    
    
    @IBOutlet weak var imagenView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        
        //OneSignal
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        let pushTokenOneSignal = status.subscriptionStatus.userId
        
        
        
        print("pushTokenOneSignal = \(pushTokenOneSignal)")
        
        pushtoken = pushTokenOneSignal ?? " "
        
        
        //GPS
        
        locMan.delegate = self
        
        locMan.requestWhenInUseAuthorization()
        
        locMan.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginController.viewTapped(gestureRecognizer:)))
        
          let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(LoginController.imageTapped(gestureRecognizer:)))
        imagenView.isUserInteractionEnabled = true
        imagenView.addGestureRecognizer(tapGesture2)
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        
        view.endEditing(true)
    }
    
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer){
        if(iconClick == true) {
            txtClave.isSecureTextEntry = false
        } else {
            txtClave.isSecureTextEntry = true
        }
        
        iconClick = !iconClick
    }
    
  
    //GPS
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        for currentLocation in locations{
            
            latitud = currentLocation.coordinate.latitude
            
            longitud = currentLocation.coordinate.longitude
            
            print("Latitud:" + String(latitud))
            
            print("Longitud:" + String(longitud))
            
        }
    }
    
    
    

  
    
    @IBAction func btnIngresar(_ sender: Any) {
        
        claveLogin = txtClave.text ?? ""
        emailLogin = txtEmail.text ?? ""
        
        
        
        if(claveLogin.count < 3 ||  claveLogin.count < 6){
            
            let alert = UIAlertController(title: "Campos Obligatorios", message: "Llene todos los campos, la clave debe ser de almenos 6 dígitos, el email almenos 3", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
        }
        else{
            
            //OneSignal
            
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            
            let pushTokenOneSignal = status.subscriptionStatus.userId
            
            
            pushtoken = pushTokenOneSignal ?? " "
            
            activityindicatorView.color = UIColor.orange
            self.view.addSubview(activityindicatorView)
            activityindicatorView.frame = self.view.frame
            activityindicatorView.center = self.view.center
            activityindicatorView.startAnimating()
            
            loginAPI()
            
        }
        
    }
    
    func loginAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "username":emailLogin,
            
            "password": claveLogin
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/auth/login",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers2).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                print("Login respuesta: ",json)
                
                guard let valor = json["message"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Login:","Login Exitoso")
                    
                    guard let valorToken = json["accessToken"] as? String else { return }
                    print("Token Interno:",valorToken)
                    
                    self.tokenInterno = valorToken
                    
                    self.defaults.set(valorToken, forKey: "tokenInterno")
                    
                    
                    
                    self.registrotokenAPI()
                    
                }
                else{
                    print("Login:","Usuario o contraseña inválidos")
                    let alert = UIAlertController(title: "Login Fallido", message: "Usuario o contraseña incorrectos.", preferredStyle: .alert)
                    self.activityindicatorView.stopAnimating()
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                let alert = UIAlertController(title: "Login Fallido", message: "Usuario o contraseña incorrectos", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                self.activityindicatorView.stopAnimating()
                
                break
            }
            
            
        }
        
        
        
        
    }
    
    
    
    func registrotokenAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            
            "tokenOneSignal": pushtoken
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/actualizarTokenOneSignal",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Registro:","Token Ingresado")
                    
                    self.agregarubicacionAPI()
                }
                else{
                    print("Registro:","Token no se pudo ingresar")
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Login Incorrecto", message: "Asegúrese de tener acceso a internet.", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Login Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
    }
    
    
    func agregarubicacionAPI(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
         self.locMan.stopUpdatingLocation()
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            
            "latitud": latitud,
            
            "longitud": longitud
        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/agregarUbicacionMovil",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta: ",json)
                
                guard let valor = json["respuesta"] as? String else { return }
                //print("respuesta 2:",valor)
                
                if(valor == "true"){
                    print("Registro:","Ubicacion Agregada")
                    
                    self.obtenerempresasAPI()
                }
                else{
                    print("Registro:","Ubicacion no agregada")
                    self.activityindicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "Login Incorrecto", message: "Asegúrese de tener acceso a internet.", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Login Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
    }
    
    func obtenerempresasAPI(){

        
        
        let parameters: Parameters = [
            
            "authHeader":tokenInterno,
            

        ]
        
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer "+tokenInterno,
            "Content-Type": "application/json"
            
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("http://192.168.0.241:8080/api/movil/obtenerEmpresas",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            
            
            switch response.result {
            case let .success(value):
                let json = value as AnyObject
                
                
                print("JSon respuesta Empresas: ",json)
                
                guard let valor = json["empresaRespuesta"] as? NSArray else { return }
                print("Arreglo de Empresas:",valor)
                
                print("Cantidad de Arreglos:",valor.count)
                for valores in valor {
                    // Do this
                    
                    //print("Arreglo",valores)
                    
                    let json = valores as AnyObject
                    
                   // print("Arreglo de Empresa: ",json)
                    
                    guard let idEmpr = json["id"] as? AnyObject else { return }
                    
                    guard let idEmpresa =  (idEmpr as? NSString)?.intValue else { return }
            
                    guard let nombreEmpr = json["nombre"] as? String else { return }
                    
                    guard let logoEmpr = json["imagen"] as? String else { return }
                    
                    
                    let insertUser = self.empresaTable.insert(self.id_tabla_empresa <- Int(idEmpresa), self.nombre_empresa <- nombreEmpr,self.logo_empresa <- logoEmpr)
                    
                    
                    do {
                        try self.database.run(insertUser)
                        print("Empresa almacenada")
                    } catch {
                        print(error)
                    }
                    
                    
                }
                self.pushBienvenida()
                
                
            case let .failure(error):
                
                let alert = UIAlertController(title: "Login Fallido", message: "Asegúrese de tener acceso a internet", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                
                self.activityindicatorView.stopAnimating()
                break
            }
            
            
        }
        
        
    }
    
    func pushBienvenida(){
        
        // Alamofire.request("https://onesignal.com/api/v1/notifications", headers: headers)
        
        let textoPush = ["en": "Te has registrado correctamente"]
        let tituloPush = ["en": "Biendenido a nuestra App"]
        let imagenPush = ["id3": "https://img.imagenescool.com/ic/bienvenidos/bienvenidos_002.jpg"]
        let parameters: Parameters = [
            "app_id": "1bfb9336-dcbb-4154-b0c3-ca2de049c1cf",
            "include_player_ids":[pushtoken],
            "ios_attachments":imagenPush,
            "contents": textoPush,
            "headings": tituloPush
        ]
        
        /*"baz": ["a", 1],
         "qux": [
         "x": 1,
         "y": 2,
         "z": 3
         ]
         */
        
        AF.request("https://onesignal.com/api/v1/notifications",method: .post,  parameters: parameters, encoding: JSONEncoding.default,headers: headers3).responseJSON { response in
            // print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                
                self.activityindicatorView.stopAnimating()
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
                self.present(viewController, animated: true, completion: nil)
                
                
                
            }else{
                self.activityindicatorView.stopAnimating()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "ContainerVC") as! ContainerVC
                self.present(viewController, animated: true, completion: nil)
            }
            
            
        }
        
        
        
    }
    
    
    
    

}
