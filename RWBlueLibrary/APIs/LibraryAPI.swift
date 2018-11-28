//
//  LibraryAPI.swift
//  RWBlueLibrary
//
//  Created by van.tien.tu on 11/28/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

/*
 Creational: Singleton.
 Structural: MVC, Decorator, Adapter, Facade.
 Behavioral: Observer, and, Memento
 */


import UIKit

// The facade design pattern
final class LibraryAPI {
  
  // Singleton
  static let shared = LibraryAPI()
  private let persistencyManager = PersistencyManager()
  private let httpClient = HTTPClient()
  private let isOnline = false
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .didDownloadImage, object: nil)
  }
  
  func getAlbums() -> [Album] {
    return persistencyManager.getAlbums()
  }
  
  func addAlbum(_ album: Album, at index: Int) {
    persistencyManager.addAlbum(album, at: index)
    if isOnline {
      httpClient.postRequest("/api/addAlbum", body: album.description)
    }
  }
  
  func deleteAlbum(at index: Int) {
    persistencyManager.deleteAlbum(at: index)
    if isOnline {
      httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
    }
  }
  
  @objc func downloadImage(with notification: Notification) {
    guard let userInfo = notification.userInfo,
      let imageView = userInfo["imageView"] as? UIImageView,
      let coverUrl = userInfo["coverUrl"] as? String,
      let filename = URL(string: coverUrl)?.lastPathComponent else {
        return
    }
    
    if let savedImage = persistencyManager.getImage(with: filename) {
      imageView.image = savedImage
      return
    }
    
    DispatchQueue.global().async {
      let downloadedImage = self.httpClient.downloadImage(coverUrl) ?? UIImage()
      DispatchQueue.main.async {
        imageView.image = downloadedImage
        self.persistencyManager.saveImage(downloadedImage, filename: filename)
      }
    }
  }
}
