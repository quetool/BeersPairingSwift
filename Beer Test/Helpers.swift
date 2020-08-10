//
//  Helpers.swift
//  Beer Test
//
//  Created by Alfredo Rinaudo on 21/07/2020.
//  Copyright © 2020 co.soprasteria. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    private let userDefaults: UserDefaults!
//    private let alamoManager: SessionManager
    init(manager: UserDefaults = UserDefaults.standard) {
        self.userDefaults = manager
    }
    
    func storeRequest(request: String) {
        self.userDefaults.set("\(request)", forKey: "last_request")
        self.userDefaults.synchronize()
    }
    
    func getLastRequest() -> String {
        if let lastSavedRequest = self.userDefaults.string(forKey: "last_request") {
            return lastSavedRequest
        }
        return ""
    }
    
    func removeLastRequest() {
        self.userDefaults.removeObject(forKey: "last_request")
        self.userDefaults.synchronize()
    }
    
    func saveSearch(searchText: String) {
        var previousSearch: [String] = getPreviousSearchs()
        if !previousSearch.contains(where: { (search) -> Bool in
            // lo que hago es controlar que searchText no haya sido buscado con anterioridad
            // ademas, no incluyo en las "suggestion strings" que son contenidas por otras strings
            // ejemplo, si busco 'Chick' pero anteriormente busqué 'Chicken', 'Chick' no será incluida
            // TODO falta hacer el caso contrario y no tener en cuenta las palabras completas
            return (search.lowercased() == searchText.lowercased() || search.lowercased().contains(searchText.lowercased()))
        }) {
            previousSearch.append(searchText)
        }
        self.userDefaults.set(previousSearch, forKey: "previous_search")
        self.userDefaults.synchronize()
    }
    
    func getPreviousSearchs() -> [String] {
        return self.userDefaults.stringArray(forKey: "previous_search")?.reversed() ?? []
    }
}
