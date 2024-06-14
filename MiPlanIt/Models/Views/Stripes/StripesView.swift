//
//  StripesView.swift
//  MiPlanIt
//
//  Created by Nikhil RajG on 06/04/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import UIKit

class StripesView: UIView {
    
    @IBInspectable var lineWidth: CGFloat = 1 { didSet { setNeedsLayout() } }
    
    @IBInspectable var lineGap: CGFloat = 1 { didSet { setNeedsLayout() } }
    
    @IBInspectable var lineColor: UIColor = .white { didSet { setNeedsLayout() }}
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        // flip y-axis of context, so (0,0) is the bottom left of the context
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -bounds.size.height)
        
        // generate a slightly larger rect than the view,
        // to allow the lines to appear seamless
        let renderRect = bounds.insetBy(dx: -lineWidth * 0.5, dy: -lineWidth * 0.5)
        
        // the total distance to travel when looping (each line starts at a point that
        // starts at (0,0) and ends up at (width, height)).
        let totalDistance = renderRect.size.width + renderRect.size.height
        
        // loop through distances in the range 0 ... totalDistance
        for distance in stride(from: 0, through: totalDistance,
                               // divide by cos(45º) to convert from diagonal length
            by: (lineGap + lineWidth) / cos(.pi / 4)) {
                
                // the start of one of the stripes
                ctx.move(to: CGPoint(
                    // x-coordinate based on whether the distance is less than the width of the
                    // rect (it should be fixed if it is above, and moving if it is below)
                    x: distance < renderRect.width ?
                        renderRect.origin.x + distance :
                        renderRect.origin.x + renderRect.width,
                    
                    // y-coordinate based on whether the distance is less than the width of the
                    // rect (it should be moving if it is above, and fixed if below)
                    y: distance < renderRect.width ?
                        renderRect.origin.y :
                        distance - (renderRect.width - renderRect.origin.x)
                ))
                
                // the end of one of the stripes
                ctx.addLine(to: CGPoint(
                    // x-coordinate based on whether the distance is less than the height of
                    // the rect (it should be moving if it is above, and fixed if it is below)
                    x: distance < renderRect.height ?
                        renderRect.origin.x :
                        distance - (renderRect.height - renderRect.origin.y),
                    
                    // y-coordinate based on whether the distance is less than the height of
                    // the rect (it should be fixed if it is above, and moving if it is below)
                    y: distance < renderRect.height ?
                        renderRect.origin.y + distance :
                        renderRect.origin.y + renderRect.height
                ))
        }
        
        // stroke all of the lines added
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.strokePath()
    }
}
