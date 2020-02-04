//
//  StringExtension.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit

fileprivate let localizationKey = "i18n_language"

extension String {
    
    var localized: String {
        
        if let _ = UserDefaults.standard.string(forKey: localizationKey) {} else {
            
            let languageStr = "en"
            
            UserDefaults.standard.set(languageStr, forKey: localizationKey)
        }
        
        let lang = UserDefaults.standard.string(forKey: localizationKey) ?? ""
        
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj") else { return self }
        guard let bundle = Bundle(path: path) else { return self }
        
        var result = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        
        if result.isEmpty { result = self }
        
        return result
    }
    
}
