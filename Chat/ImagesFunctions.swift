//
//  ImagesFunctions.swift
//  ChatFramework
//
//  Created by TRIMECH on 20/04/2018.
//  Copyright © 2018 macbook pro. All rights reserved.
//

import Foundation
@objc public class ImagesFunctions : NSObject{
    
    
public class func convertImageToBase64(image: UIImage) -> (String) {
    
    let comressedImage = scaleUIImageToSize(image: image,size:CGSize(width: 300, height: 300))
    let imageData  = UIImageJPEGRepresentation(comressedImage,0.0)
    
    
    let base64StringToEncrypt = imageData?.base64EncodedString(options: .lineLength64Characters)
    
    return base64StringToEncrypt!
    
}






    public class func convertBase64ToImage(base64String: String) -> UIImage {
        let decodedimage: UIImage!
        
        
        let dataDecoded : Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)!
        decodedimage = UIImage(data: dataDecoded)
        
        return decodedimage
        
    }
public class func scaleUIImageToSize(image: UIImage,size: CGSize) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: size))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return (scaledImage)!
}
}
