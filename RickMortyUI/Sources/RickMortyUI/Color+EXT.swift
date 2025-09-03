//
//  Color+EXT.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 31.08.2025.
//

#if canImport(UIKit)
import UIKit

import SwiftUI

public extension Color {
    static var lightBlue: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1)
            : UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 1)
        })
    }
    
    static var lightRed: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1)
            : UIColor(red: 1.0, green: 0.90, blue: 0.90, alpha: 1)
        })
    }
    
    static let lightGray = Color.gray.opacity(0.3)
}


public extension Color {
    enum CaracterCard {
        public enum Status {
            public static let alive = Color.lightBlue
            public static let dead = Color.lightRed
            public static let unknown = Color(.systemBackground)
        }
        
        public enum Border {
            public static let alive = Color.lightBlue
            public static let dead = Color.lightRed
            public static let unknown = Color.lightGray
        }
    }
    
    enum CaracterDetails {
        public enum Status {
            public enum Background {
                public static let alive = Color.lightBlue
                public static let dead = Color.lightRed
                public static let unknown = Color.lightGray
            }
        }
    }
}

#else
import SwiftUI
import AppKit

public extension Color {
    static var lightBlue: Color {
        // macOS fallback (no traitCollection)
        Color(NSColor(calibratedRed: 0.75, green: 0.85, blue: 1.0, alpha: 1))
    }
    
    static var lightRed: Color {
        Color(NSColor(calibratedRed: 1.0, green: 0.90, blue: 0.90, alpha: 1))
    }
    
    enum StatusColor {
        public static let alive = Color.lightBlue
        public static let dead = Color.lightRed
        public static let unknown = Color(NSColor.windowBackgroundColor)
    }
}
#endif
