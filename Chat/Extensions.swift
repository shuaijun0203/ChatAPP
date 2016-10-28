//
//  Extensions.swift
//  Chat
//
//  Created by guest on H28/10/25.
//  Copyright © 平成28年 jp.ac.jec.15cm. All rights reserved.
//

import UIKit

let imageCache : NSCache = NSCache<AnyObject,AnyObject>()

extension UIImageView {
    
    func downloadUIImageWithURLString(urlString:String){
        self.image  = nil
        
        let profileImageUrl = NSURL(string: urlString)
        
        if let profileImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = profileImage
            return
        }
        
        URLSession.shared.dataTask(with: profileImageUrl! as URL, completionHandler: { (data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadProfileImage = UIImage(data: data!){
                    imageCache.setObject(downloadProfileImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadProfileImage

                }
            }
        }).resume()
    }
    
}
