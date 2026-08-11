//
//  WobblyBlobShape.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct WobblyBlobShape: Shape {
    var amplitude: CGFloat
    var phase: CGFloat
    var waveFrequencyFactor: CGFloat = 1.0
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(amplitude, phase) }
        set {
            amplitude = newValue.first
            phase = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 - 20
        
        let pointsCount = 72
        for i in 0..<pointsCount {
            let angle = CGFloat(i) * (2 * .pi) / CGFloat(pointsCount)
            
            let offset1 = sin(angle * 8.0 + phase) * (amplitude * 0.45)
            let offset2 = cos(angle * 6.0 - phase * 1.5) * (amplitude * 0.35)
            let offset3 = sin(angle * 10.0 + phase * 0.8) * (amplitude * 0.20)
            let r = baseRadius + (offset1 + offset2 + offset3) * waveFrequencyFactor
            
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
