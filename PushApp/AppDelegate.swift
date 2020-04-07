//
//  AppDelegate.swift
//  PushApp
//
//  Created by Latinus Programador on 6/25/19.
//  Copyright © 2019 Latinus. All rights reserved.
//

import UIKit
import OneSignal
import SQLite

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Bandeja
    
    var database: Connection!
    
    let usersTable = Table("bandeja")
    let id = Expression<Int>("id_bandeja")
    let titulo = Expression<String>("titulo_bandeja")
    let contenido = Expression<String>("contenido_bandeja")
    let fecha = Expression<String>("fecha_bandeja")
    let data = Expression<String>("data_bandeja")
    let imagen = Expression<String>("imagen_bandeja")
    let url = Expression<String>("url_bandeja")
    
    
   
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //SQL Bandeja
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("bandeja").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        
        //SQL Bandeja
        
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.titulo)
              table.column(self.contenido)
              table.column(self.fecha)
            table.column(self.data)
             table.column(self.imagen)
             table.column(self.url)
 
            
             
            
        }
        
        do {
            try self.database.run(createTable)
            print("Tabla Bandeja Creada")
        } catch {
            print("Error al crear la tabla")
            print(error)
        }
        
        
        
        
        
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            
       

        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fecha  = "Fecha"
            var data = " "
            var imagen = " "
            
            var fullMessage = payload.body
            print("Message = \(fullMessage)")
            
            
            imagen = payload.attachments[AnyHashable("id3")]! as! String
            
            if payload.additionalData != nil {
                
                 print("DataAdicional = \(payload.additionalData)")
                
                let additionalData = payload.additionalData
                
                 fecha = additionalData?["fecha"] as! String
                data = additionalData?["data"] as! String
                
                print("DataAdicionalFecha = \(fecha)")
                
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
                }
            }
            
        
            
            let insertUser = self.usersTable.insert(self.titulo <- payload.title ?? " ", self.contenido <- payload.body ?? " ", self.fecha <- fecha, self.data <- data,self.imagen <- imagen ,self.url <- payload.launchURL ?? " ")
            
            //,self.imagen <- payload.attachments[0] as! String,
            do {
                try self.database.run(insertUser)
                print("Notificación creada")
            } catch {
                print(error)
            }
        }

        
        
        /*
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification - \(notification?.payload.notificationID) - \(notification?.payload.title)")
        }
        
      let notificationOpenedBlock: OSHandleNotificationReceivedBlock = { result in
            
        // This block gets called when the user reacts to a notification received
        let payload: OSNotificationPayload = result!.payload
        var fullMessage = payload.body
        
        print("Message = \(payload)")
         }
 
         */
        
       /* let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            print("launchURL = \(notification?.payload.launchURL ?? "None")")
            print("content_available = \(notification?.payload.contentAvailable ?? false)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body)")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    // For presenting a ViewController from push notification action button
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let instantiateRedViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RegistroController") as UIViewController
                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "EmpresasController") as UIViewController
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("do something when button 2 is pressed")
                        self.window?.rootViewController = instantiateRedViewController
                        self.window?.makeKeyAndVisible()
                        
                        
                    } else if actionID == "id1" {
                        print("do something when button 1 is pressed")
                        self.window?.rootViewController = instantiatedGreenViewController
                        self.window?.makeKeyAndVisible()
                        
                    }
                }
            }
        }
            */
        
        
        
        let onesignalInitSettings =  [kOSSettingsKeyAutoPrompt: false,
                                      kOSSettingsKeyInAppLaunchURL: true]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "1bfb9336-dcbb-4154-b0c3-ca2de049c1cf",
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        
       // let insertUser = self.usersTable.insert(self.titulo <- "Aprovecha esta promo", self.contenido <- "Esta promoción es para tí")
        
       
        
   

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

