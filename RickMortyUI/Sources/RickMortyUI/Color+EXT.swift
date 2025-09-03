//
//  Color+EXT.swift
//  RickMortyUI
//
//  Created by Abdelrahman Mohamed on 31.08.2025.
//

import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public extension Color {
    static var lightBlue: Color {
        #if os(iOS)
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1)
            : UIColor(red: 0.85, green: 0.93, blue: 1.0, alpha: 1)
        })
        #else
        // macOS fallback (no traitCollection)
        Color(NSColor(calibratedRed: 0.75, green: 0.85, blue: 1.0, alpha: 1))
        #endif
    }
    
    static var lightRed: Color {
        #if os(iOS)
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.15, blue: 0.15, alpha: 1)
            : UIColor(red: 1.0, green: 0.90, blue: 0.90, alpha: 1)
        })
        #else
        // macOS fallback (no traitCollection)
        Color(NSColor(calibratedRed: 1.0, green: 0.90, blue: 0.90, alpha: 1))
        #endif
    }
    
    static let lightGray = Color.gray.opacity(0.3)
}


public extension Color {
    enum CharacterCard {
        public enum Status {
            public static let alive = Color.lightBlue
            public static let dead = Color.lightRed
            public static let unknown = Color.lightGray
        }
        
        public enum Border {
            public static let alive = Color.lightBlue
            public static let dead = Color.lightRed
            public static let unknown = Color.lightGray
        }
    }
    
    enum CharacterDetails {
        public enum Status {
            public enum Background {
                public static let alive = Color.lightBlue
                public static let dead = Color.lightRed
                public static let unknown = Color.lightGray
            }
        }
    }
}
