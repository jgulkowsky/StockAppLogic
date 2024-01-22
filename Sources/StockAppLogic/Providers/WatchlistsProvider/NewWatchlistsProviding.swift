//
//  NewWatchlistsProviding.swift
//  
//
//  Created by Jan Gulkowski on 22/01/2024.
//

import Foundation

// todo: remove all New prefixes when finished (everywhere)

public protocol NewWatchlistsProviding {
    func getWatchlists() async throws -> [Watchlist]
    func postWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
    func updateWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
    func deleteWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
}

public class NewWatchlistsProvider: NewWatchlistsProviding {
    public enum NewWatchlistsProviderError: Error {
        case get
        case post
        case update
        case delete
        case dataSourceNotInjected(String)
    }
    
    private var dataSourceRemote: NewWatchlistsDataSource?
    private var dataSourceLocal: NewWatchlistsDataSource?
    
    public init(
        dataSourceRemote: NewWatchlistsDataSource? = nil,
        dataSourceLocal: NewWatchlistsDataSource? = nil
    ) {
        self.dataSourceRemote = dataSourceRemote
        self.dataSourceLocal = dataSourceLocal
    }
    
    public func getWatchlists() async throws -> [Watchlist] {
        guard let dataSourceRemote = dataSourceRemote else {
            throw NewWatchlistsProviderError.dataSourceNotInjected("no remote datasource")
        }
        
        do {
            return try await dataSourceRemote.getWatchlists()
        } catch {
            throw NewWatchlistsProviderError.get
        }
    }
    
    public func postWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        guard let dataSourceRemote = dataSourceRemote else {
            throw NewWatchlistsProviderError.dataSourceNotInjected("no remote datasource")
        }
        
        do {
            return try await dataSourceRemote.postWatchlists(watchlists)
        } catch {
            throw NewWatchlistsProviderError.post
        }
    }
    
    public func updateWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        guard let dataSourceRemote = dataSourceRemote else {
            throw NewWatchlistsProviderError.dataSourceNotInjected("no remote datasource")
        }
        
        do {
            return try await dataSourceRemote.postWatchlists(watchlists)
        } catch {
            throw NewWatchlistsProviderError.update
        }
    }
    
    public func deleteWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        guard let dataSourceRemote = dataSourceRemote else {
            throw NewWatchlistsProviderError.dataSourceNotInjected("no remote datasource")
        }
        
        do {
            return try await dataSourceRemote.postWatchlists(watchlists)
        } catch {
            throw NewWatchlistsProviderError.delete
        }
    }
}

public protocol NewWatchlistsDataSource {
    func getWatchlists() async throws -> [Watchlist]
    func postWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
    func updateWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
    func deleteWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist]
}

// todo: we could implement NewWatchlistsDataSourceRemote but we don't need this - that's why we have it as optional - but in future with this design we have such oportunity easily - as well as updating logic in NewWatchlistsProvider so it uses remote or both in any order it needs

import CoreData

public class NewWatchlistsDataSourceLocal: NewWatchlistsDataSource {
    public enum NewWatchlistsDataSourceLocalError: Error {
        case get
        case post
        case update
        case delete
    }
    
    private let viewContext = PersistenceController.shared.viewContext
    
    public init() {}
    
    public func getWatchlists() async throws -> [Watchlist] {
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
    
    public func postWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        let watchlist = watchlists[0] // todo: this is just poc - normally we would add all the watchlists but for now we assume there's only one as we copied code that supports one watchlist to add
        let watchlistEntity = WatchlistEntity(context: viewContext)
        watchlistEntity.id = watchlist.id
        watchlistEntity.name = watchlist.name
        
        watchlist.symbols.forEach { symbol in
            let symbolEntity = SymbolEntity(context: viewContext)
            symbolEntity.value = symbol
            watchlistEntity.addToSymbols(symbolEntity)
        }
        
        saveToCoreData()
        
        return [] // todo: we also need to return current watchlists state
    }
    
    public func updateWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        let watchlist = watchlists[0] // todo: this is just poc - normally we would update all the watchlists but for now we assume there's only one as we copied code that supports one watchlist to update (and only to add a symbol / we need to delete the symbol / update it and update the name for the watchlist too)
        let symbol = watchlist.symbols[0] // todo: same as above it's poc - we just get first symbol passed but we need to check for all the watchlists and all the symbols that does not match
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else {
            throw NewWatchlistsDataSourceLocalError.update
        }
        
        let symbolEntity = SymbolEntity(context: viewContext)
        symbolEntity.value = symbol
        watchlistEntity.addToSymbols(symbolEntity)
        
        saveToCoreData()
        
        return [] // todo: we also need to return current watchlists state
        
        
        // todo: this is some code for deletion one symbol from watchlist - we need to update it so it support many watchlists many symbols
//        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id),
//              let symbolEntity = getSymbolEntity(of: watchlistEntity, withValue: symbol) else { return }
//
//        viewContext.delete(symbolEntity)
//        watchlistEntity.removeFromSymbols(symbolEntity)
//
//        saveToCoreData()
    }
    
    public func deleteWatchlists(_ watchlists: [Watchlist]) async throws -> [Watchlist] {
        let watchlist = watchlists[0] // todo: this is just poc - normally we would delete all the watchlists but for now we assume there's only one as we copied code that supports one watchlist to delete
        guard let watchlistEntity = getWatchlistEntity(withId: watchlist.id) else {
            throw NewWatchlistsDataSourceLocalError.delete
        }
        
        viewContext.delete(watchlistEntity)
        // don't have to worry about symbolEntities - they will be removed with delete rule cascade in relationships
        
        saveToCoreData()
        
        return [] // todo: we also need to return current watchlists state
    }
}

private extension NewWatchlistsDataSourceLocal {
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
