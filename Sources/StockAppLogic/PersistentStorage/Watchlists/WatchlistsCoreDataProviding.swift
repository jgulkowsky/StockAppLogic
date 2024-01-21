//
//  WatchlistsCoreDataProviding.swift
//  StockAppLogic
//
//  Created by Jan Gulkowski on 04/01/2024.
//

import Foundation

public protocol WatchlistsCoreDataProviding {
    func getWatchlists() -> [Watchlist] // GET - maybe sth like: fetchData (request?, mapper<DTO?, Model>)
    func addWatchlist(_ watchlist: Watchlist) // POST
    func addSymbolToWatchlist(_ symbol: String, _ watchlist: Watchlist) // UPDATE
    func removeSymbolFromWatchlist(_ symbol: String, _ watchlist: Watchlist) // UPDATE
    func deleteWatchlist(_ watchlist: Watchlist) // DELETE
}

// todo: first of all we need to abstract CoreData and ApiFetcher so providers will know only the DataSourceProviding protocol and we will inject DataSourceProvider object there where one object (e.g. related with watchlists) will get data from CoreData and the other one (e.g. related with symbols) will get data from the api - and providers don't know where data is from - this will make our app more elastic to changes (if in any point of time we need to change api call to core data or core data to realm or to user defaults or keychain)
// todo: the other thing: WatchlistsCoreDataProviding exposes all the CRUD methods where ApiFetcher eposes only GET - this should be aligned - if we don't have other CRUD methods than GET for the ApiFetcher (we don't use them in code) we should not implement them - some unimplemented error will happen and this is okay for now as we don't need this functionality - but we are open for further development
// todo: the other other thing is that WatchlistsCoreDataProviding is data oriented protocol where ApiFetcher is just feed with some model we want to get and the decoder that should be used - we should also align this so WatchlistsCoreDataProviding is generic and will get data and decoder (but does it need it now?) - anyway it need to be aligned in some way until this branch is finished
