//
//  UIImageView+Ext.swift
//  RWBlueLibrary
//
//  Created by Văn Tiến Tú on 11/28/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

extension UIImageView {
  
  func downloadImage(_ url: String, completion: @escaping (UIImage?) -> ()) {
    let aUrl = URL(string: url)
    guard let data = try? Data(contentsOf: aUrl!), let image = UIImage(data: data) else {
      completion(nil)
      return
    }
    self.image = image
    completion(image)
  }
}
