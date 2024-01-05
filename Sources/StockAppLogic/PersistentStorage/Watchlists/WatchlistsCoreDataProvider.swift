//
//  WatchlistsCoreDataProvider.swift
//  StockApp
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import Foundation
import CoreData

class WatchlistsCoreDataProvider: WatchlistsCoreDataProviding {
    private let viewContext = PersistenceController.shared.viewContext
    
    func getWatchlists() -> [Watchlist] {
        let watchlistEntities = getWatchlistEntities()
        let watchlists = watchlistEntities.map { watchlistEntity in
            let symbolEntities = getSymbolEntities(of: watchlistEntity)
            
            return Watchlist(
                id: watchlistEntity.id!,
                name: watchlistEntity.name!,
                symbols: symbolEntities.map { $0.value! }
            )
        }
        return watchlists
    }
    
    func addWatchlist(_ watchlist: Watchlist) {
        let watchlistEntity = WatchlistEntity(context: viewContext)
        watchlistEntity.id = watchlist.id
        watchlistEntity.name = watchlist.name
        
        watchlist.symbols.forEach { symbol in
            let symbolEntity = SymbolEntity(context: viewContext)
            symbolEntity.value = symbol
            watchlistEntity.addToSymbols(symbolEntity)
        }
        
        saveToCoreData()
    }
    
    func addSymbolToWatchlist(_ symbol: String, _ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else { return }
        
        let symbolEntity = SymbolEntity(context: viewContext)
        symbolEntity.value = symbol
        watchlistEntity.addToSymbols(symbolEntity)
        
        saveToCoreData()
    }
    
    
    func removeSymbolFromWatchlist(_ symbol: String, _ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id),
              let symbolEntity = getSymbolEntity(of: watchlistEntity, withValue: symbol) else { return }
        
        viewContext.delete(symbolEntity)
        watchlistEntity.removeFromSymbols(symbolEntity)
        
        saveToCoreData()
    }
    
    func deleteWatchlist(_ watchlist: Watchlist) {
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else { return }
        
        viewContext.delete(watchlistEntity)
        // don't have to worry about symbolEntities - they will be removed with delete rule cascade in relationships
        
        saveToCoreData()
    }
}

private extension WatchlistsCoreDataProvider {
    func getWatchlistEntities(withId id: UUID? = nil) -> [WatchlistEntity] {
        func getRequest() -> NSFetchRequest<WatchlistEntity> {
            let request = NSFetchRequest<WatchlistEntity>(entityName: "WatchlistEntity")
            if let id = id {
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            }
            return request
        }
        do {
            let request = getRequest()
            let entities = try viewContext.fetch(request)
            return entities
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func getWatchlistEntity(withId id: UUID) -> WatchlistEntity? {
        return getWatchlistEntities(withId: id).first
    }
    
    func getSymbolEntities(of watchlistEntity: WatchlistEntity, withValue value: String? = nil) -> [SymbolEntity] {
        func getRequest() -> NSFetchRequest<SymbolEntity> {
            let request = NSFetchRequest<SymbolEntity>(entityName: "SymbolEntity")
            let watchlistPredicate = NSPredicate(format: "watchlist == %@", watchlistEntity)
            
            var valuePredicate: NSPredicate?
            if let value = value {
                valuePredicate = NSPredicate(format: "value == %@", value)
            }
            
            let compoundPredicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [watchlistPredicate, valuePredicate].compactMap { $0 }
            )
            request.predicate = compoundPredicate
            
            return request
        }
        do {
            let request = getRequest()
            let entities = try viewContext.fetch(request)
            return entities
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
            return []
        }
    }
    
    func getSymbolEntity(of watchlistEntity: WatchlistEntity, withValue value: String) -> SymbolEntity? {
        return getSymbolEntities(of: watchlistEntity, withValue: value).first
    }
    
    func saveToCoreData() {
        do {
            try viewContext.save()
        } catch {
            print("@jgu: Error in \(#fileID).\(#function)")
        }
    }
}
