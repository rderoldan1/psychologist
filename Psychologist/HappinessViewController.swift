//
//  HappinessViewController.swift
//  Happiness
//
//  Created by Ruben Espinosa Roldan on 6/09/15.
//  Copyright © 2015 Ruben Espinosa Roldan. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, FaceViewDataSource {
  
  
  @IBOutlet weak var faceView: FaceView! {
    didSet {
      faceView.dataSource = self
      faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
    }
  }
  
  private struct Constants {
    static let HappinessGesturesScale: CGFloat = 4
  }
  
  @IBAction func changeHappiness(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .Ended: fallthrough
    case .Changed:
      let translation = gesture.translationInView(faceView)
      let happinessChange = -Int(translation.y / Constants.HappinessGesturesScale)
      if happinessChange != 0 {
        happiness += happinessChange
        gesture.setTranslation(CGPointZero, inView: faceView)
      }
    default: break
    }
  }
  
  // 0 = Very Sad
  // 100 = Ecstatic
  var happiness: Int = 50 {
    didSet {
      min(max(happiness, 0), 100 )
      updateUI()
    }
  }
  
  func updateUI() {
    faceView?.setNeedsDisplay()
    title = "\(happiness)"
  }
  
  func smilinessForFaceView(sender: FaceView) -> Double? {
    return Double(happiness - 50) / 50
  }
  
}
