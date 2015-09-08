//
//  FaceView.swift
//  Happiness
//
//  Created by Ruben Espinosa Roldan on 6/09/15.
//  Copyright © 2015 Ruben Espinosa Roldan. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
  func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
  
  @IBInspectable
  var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() }  }
  @IBInspectable
  var color: UIColor = UIColor.greenColor() { didSet { setNeedsDisplay() } }
  @IBInspectable
  var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() }  }
  
  var faceCenter: CGPoint{
    return convertPoint(center, fromView: superview)
  }
  
  var faceRadious: CGFloat {
    return min(bounds.size.width, bounds.size.height) / 2 * scale
  }
  
  weak var dataSource: FaceViewDataSource?
  
  func scale(gesture: UIPinchGestureRecognizer){
    if gesture.state == .Changed {
      scale *= gesture.scale
      gesture.scale = 1
    }
  }
  
  private struct Scaling {
    static let FaceRadiousToEyeRadiousRatio: CGFloat = 10
    static let FaceRadiousToEyeOffsetRatio: CGFloat = 3
    static let FaceRadiousToEyeSeparationRatio: CGFloat = 1.5
    static let FaceRadiousToMouthWidthRatio: CGFloat = 1
    static let FaceRadiousToMouthHeightRatio: CGFloat = 3
    static let FaceRadiousToMouthOffsetRatio: CGFloat = 3
  }
  
  private enum Eye {
    case Left, Right
  }
  
  private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
    let eyeRadious = faceRadious / Scaling.FaceRadiousToEyeRadiousRatio
    let eyeVerticalOffset = faceRadious / Scaling.FaceRadiousToEyeOffsetRatio
    let eyeHorizontalSeparation = faceRadious / Scaling.FaceRadiousToEyeSeparationRatio
    
    var eyeCenter = faceCenter
    eyeCenter.y -= eyeVerticalOffset
    
    switch whichEye {
    case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
    case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
    }
    
    let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadious, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
    path.lineWidth = lineWidth
    
    return path
    
  }
  
  private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath{
    let mouthWidth = faceRadious / Scaling.FaceRadiousToMouthWidthRatio
    let mouthHeight = faceRadious / Scaling.FaceRadiousToMouthHeightRatio
    let mouthVerticalOffset = faceRadious / Scaling.FaceRadiousToMouthOffsetRatio
    
    let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1 )) * mouthHeight
    let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
    let end = CGPoint(x: start.x + mouthWidth, y: start.y)
    let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
    let cp2 = CGPoint(x: end.x - mouthWidth / 3 , y: cp1.y)
    
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
    path.lineWidth = lineWidth
    
    return path
    
  }
  
  
  override func drawRect(rect: CGRect) {
    let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadious, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
    facePath.lineWidth = lineWidth
    color.set()
    facePath.stroke()
    
    bezierPathForEye(.Left).stroke()
    bezierPathForEye(.Right).stroke()
    
    let smile = dataSource?.smilinessForFaceView(self) ?? 0.0
    bezierPathForSmile(smile).stroke()
  }
}
