//
//  LocalManager.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation

fileprivate let appleLanguageKey = "AppleLanguages"

enum Language: String {
    
    case english = "en"
    case ukrainian = "uk"
    case russian = "ru"
    
    var languageName: String {
        switch self {
        case .english: return "English"
        case .ukrainian: return "Українська"
        case .russian: return "Русский"
        }
    }
}

class LocalManager: NSObject {
    
    static let shared = LocalManager()
     
    func currentAppleLanguage() -> String {
        let langArray = UserDefaults.standard.object(forKey: appleLanguageKey) as! NSArray
        guard let current = langArray.firstObject as? String else { return "" }
        let endIndex = current.startIndex
        let currentWithoutLocale = String(current[..<current.index(endIndex, offsetBy: 2)])
        
        return currentWithoutLocale
    }
    
    func setAppleLanguageTo(lang: Language) {
        UserDefaults.standard.set([lang.rawValue, currentAppleLanguage()], forKey: appleLanguageKey)
    }
    
}
