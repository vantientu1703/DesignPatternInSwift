
//
//  HorizontalScrollerView.swift
//  RWBlueLibrary
//
//  Created by Văn Tiến Tú on 11/28/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

// The adapter

import UIKit

@objc protocol HorizontalScrollerViewDataSource: class {
  // Ask the data source how many views it wants to present inside the horizontal scroller
  @objc func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  // Ask the data source to return the view that should appear at <index>
  @objc func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

@objc protocol HorizontalScrollerViewDelegate: class {
  // inform the delegate that the view at <index> has been selected
  @objc optional func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}


class HorizontalScrollerView: UIView {
  
  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?
  
  // 1
  private enum ViewConstants {
    static let Padding: CGFloat = 10
    static let Dimensions: CGFloat = 100
    static let Offset: CGFloat = 100
  }
  
  // 2
  private let scroller = UIScrollView()
  
  // 3
  private var contentViews = [UIView]()
  private var currentIndex: Int = 0
  private var containerView: UIView?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    //1
    addSubview(scroller)
    //2
    scroller.translatesAutoresizingMaskIntoConstraints = false
    //3
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])
    //4
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scroller.addGestureRecognizer(tapRecognizer)
    scroller.delegate = self
  }
  
  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
//    UIView.animate(withDuration: 0.3) {
      self.scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
//    }
  }
  
  @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scroller)
    guard
      let index = contentViews.index(where: { $0.frame.contains(location)})
      else { return }
    
    delegate?.horizontalScrollerView?(self, didSelectViewAt: index)
    scrollToView(at: index)
    self.currentIndex = index
  }
  
  func view(at index :Int) -> UIView {
    return contentViews[index]
  }
  
  func reload() {
    // 1 - Check if there is a data source, if not there is nothing to load.
    guard let dataSource = dataSource else {
      return
    }
    
    //2 - Remove the old content views
    contentViews.forEach { $0.removeFromSuperview() }
    self.containerView?.removeFromSuperview()
    
    let numberOfViews = dataSource.numberOfViews(in: self)
    // 3 - xValue is the starting point of each view inside the scroller
    var xValue = ViewConstants.Offset
    // 4 - Fetch and add the new views
    let widthView = ViewConstants.Offset + ViewConstants.Dimensions * CGFloat(numberOfViews) + CGFloat(numberOfViews - 1) * ViewConstants.Padding
    self.containerView = UIView(frame: CGRect(x: 0, y: ViewConstants.Padding, width: widthView, height: ViewConstants.Dimensions))
    self.containerView?.backgroundColor = .red
    if let containerView = self.containerView {
      self.scroller.addSubview(containerView)
      contentViews = (0..<numberOfViews).map {
        index in
        // 5 - add a view at the right position
//        xValue += ViewConstants.Padding
        let view = dataSource.horizontalScrollerView(self, viewAt: index)
        view.frame = CGRect(x: CGFloat(xValue), y: 0, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
        containerView.addSubview(view)
        xValue += ViewConstants.Dimensions + ViewConstants.Padding
        return view
      }
      // 6
      scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
    }
  }
  
  func reloadView(at index: Int) {
    guard let dataSource = self.dataSource else { return }
    if index < self.contentViews.count {
      let view = dataSource.horizontalScrollerView(self, viewAt: index)
      view.setNeedsDisplay()
    }
  }
  
  func insertView(at index: Int) {
    
  }
  
  func deleteView(at index: Int) {
    
  }
  
  private func centerCurrentView() {
    let centerRect = CGRect(
      origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
      size: CGSize(width: ViewConstants.Padding, height: bounds.height)
    )
    
    guard let selectedIndex = contentViews.index(where: { $0.frame.intersects(centerRect) })
      else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
//    UIView.animate(withDuration: 0.3) {
      self.scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
//    }
    delegate?.horizontalScrollerView?(self, didSelectViewAt: selectedIndex)
    self.currentIndex = selectedIndex
  }
}

extension HorizontalScrollerView: UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}

