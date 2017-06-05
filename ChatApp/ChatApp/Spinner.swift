//
//  LoadingOverlay.swift
//  ChatApp
//
//  Created by Sergio Raul Carreño Aranguiz on 6/5/17.
//  Copyright © 2017 Sergio Raul Carreño Aranguiz. All rights reserved.
//

import Foundation
import UIKit

public class Spinner : UIView{
    
    var activitySpinner: UIActivityIndicatorView
    var loadingLabel: UILabel
    
    
    override init(frame: CGRect){
        activitySpinner = UIActivityIndicatorView()
        loadingLabel = UILabel()
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.alpha = 0.75
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        let labelHeight = 22
        let labelWidth = frame.width - 20
        
        //center x & y
        let centerX = frame.width / 2
        let centerY = frame.height / 2
        
        //activity spinner
        
        activitySpinner.activityIndicatorViewStyle = .whiteLarge
        activitySpinner.frame = CGRect(x: centerX - (activitySpinner.frame.width / 2), y: centerY - activitySpinner.frame.height - 20, width: activitySpinner.frame.width, height: activitySpinner.frame.height)
        activitySpinner.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(activitySpinner)
        activitySpinner.startAnimating()
        
        
        
        loadingLabel.frame = CGRect(x: centerX - (labelWidth / 2), y: centerY + 20, width: labelWidth, height: CGFloat(labelHeight))
        loadingLabel.backgroundColor = UIColor.clear
        loadingLabel.textColor = UIColor.white
        loadingLabel.text = "Please wait..."
        loadingLabel.textAlignment = .center
        loadingLabel.autoresizingMask =  [.flexibleHeight, .flexibleWidth]
        addSubview(loadingLabel)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func hide(){
        UIView.animate(withDuration: 0.5, animations: { 
            self.alpha = 0
        }) { (completed) in
            self.removeFromSuperview()
        }
    }
   
}
