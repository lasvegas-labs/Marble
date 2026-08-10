import SwiftUI

public struct OrbConfiguration {
    public var primaryColor: Color
    public var secondaryColor: Color
    public var brightness: Double
    public var animationSpeed: Double
    
    public init(primaryColor: Color, secondaryColor: Color, brightness: Double, animationSpeed: Double) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.brightness = brightness
        self.animationSpeed = animationSpeed
    }
}
