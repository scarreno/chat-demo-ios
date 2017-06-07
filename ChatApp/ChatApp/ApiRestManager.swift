//
//  ApiRestManager.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/6/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation

public class ApiRestManager: NSObject {
    
    let uri = "http://lagash-test-api.azurewebsites.net/api/form"
    var users = [UserForm]()
    
        func getUsers(completionHandler: @escaping ([UserForm]?, NSError?) -> Void ) -> URLSessionTask {
            
            users.removeAll()
            
            let url = URL(string: uri)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if error != nil{
                    completionHandler(nil, error as! NSError)
                    return
                }else {
                    do {
                        
                        if let responseData = data {
                            let parsedData = try JSONSerialization.jsonObject(with: responseData, options: []) as! [AnyObject]
                            
                            
                            for object in parsedData {
                                if let name = object["Name"], let email = object["Email"], let uid = object["id"] {
                                    let user = UserForm()
                                    user.name = name as! String
                                    user.email = email as! String
                                    user.userId = uid as! String
                                    self.users.append(user)
                                }
                            }
                            
                            completionHandler(self.users, nil)
                            return
                        }
                        
                    } catch let error as NSError {
                        completionHandler(nil, error)
                    }
                }
               
                /*
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControlView?.endRefreshing()
                }*/
            }
            task.resume()
            
            return task
        }
    
    func addUser(name: String, email: String, completionHandler: @escaping (String?, NSError?) -> Void ){
        
        let dictionary = ["Name": name, "Email": email] as [String: AnyObject]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted]){
            let url = URL(string: uri)!
            
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if error != nil{
                    completionHandler(nil, error as! NSError)
                    return
                }
                
                if let responseData = data , let responseString = String(data: responseData, encoding: .utf8) {
                    completionHandler(responseString, nil)
                }
            }
            
            task.resume()
        }
        
    }
    
    
    func updateUser(user: UserForm, completionHandler: @escaping (String?, NSError?) -> Void ){
        
        let dictionary = ["Name": user.name, "Email": user.email, "id": user.userId] as [String: AnyObject]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted]){
            let url = URL(string: uri)!
            
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                if error != nil{
                    completionHandler(nil, error as! NSError)
                    return
                }
                
                if let responseData = data , let responseString = String(data: responseData, encoding: .utf8) {
                    completionHandler(responseString, nil)
                }
            }
            
            task.resume()
        }
        
    }
    
}
