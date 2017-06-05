//
//  BaseViewController.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/5/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation
import UIKit

public class BaseTableViewController: UITableViewController {
    
    let spinner = Spinner(frame: UIScreen.main.bounds)

    
    func showSpinner(){
        UIApplication.shared.keyWindow?.addSubview(spinner)
    }
    
    
    func hideSpinner(){
        if spinner != nil {
            spinner.hide()
        }
    }
    
   
}
