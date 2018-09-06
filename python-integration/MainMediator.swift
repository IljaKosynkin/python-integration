//
//  MainMediator.swift
//  python-integration
//
//  Created by Ilja Kosynkin on 29/08/2018.
//  Copyright © 2018 Syllogismobile. All rights reserved.
//

import Foundation
import CoreData

final class MainMediator {
    private static let url: String = "https://xkcd.com/info.0.json"
    private static let config: URLSessionConfiguration = URLSessionConfiguration.default
    private static let session: URLSession = URLSession(configuration: config)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "d-MM-yyyy"
        return formatter
    }()
    
    func load(onSuccess: @escaping (AppWebcomic) -> Void, onError: @escaping (String) -> Void) {
        guard let url: URL = URL(string: MainMediator.url) else { return }
        let request: URLRequest = URLRequest(url: url)
        
        let task: URLSessionDataTask = MainMediator.session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                self.loadFromDB(onSuccess: onSuccess, onError: onError)
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            guard let data: Data = data else {
                self.loadFromDB(onSuccess: onSuccess, onError: onError)
                print("Error: did not receive data")
                return
            }
            
            guard let xkcd: [String: Any] = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                self.loadFromDB(onSuccess: onSuccess, onError: onError)
                print("JSON deserialization failed")
                return
            }
            
            guard let netComic: NetWebcomic = self.convert(response: xkcd) else { onError("Conversion failed"); return }
            
            let fetch: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: DBWebcomic.self))
            let request: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                try AppDelegate.shared?.context.execute(request)
            } catch {
                print(error.localizedDescription)
            }
            
            let db: DBWebcomic = self.convert(net: netComic)
            AppDelegate.shared?.context.insert(db)
            
            do {
                try AppDelegate.shared?.context.save()
            } catch {
                self.loadFromDB(onSuccess: onSuccess, onError: onError)
                print(error.localizedDescription)
                return
            }
            
            onSuccess(self.convert(database: db))
        }
        
        task.resume()
    }
    
    private func loadFromDB(onSuccess: @escaping (AppWebcomic) -> Void, onError: @escaping (String) -> Void) {
        let request: NSFetchRequest<DBWebcomic> = NSFetchRequest<DBWebcomic>(entityName: String(describing: DBWebcomic.self))

        guard let result: DBWebcomic = (try? AppDelegate.shared?.context.fetch(request))??.first else {
            onError("Failed")
            return
        }
        
        onSuccess(self.convert(database: result))
    }

    private func convert(response: [String: Any]) -> NetWebcomic? {
        guard let day: String = response["day"] as? String,
            let month: String = response["month"] as? String,
            let year: String = response["year"] as? String,
            let title: String = response["safe_title"] as? String,
            let desc: String = response["alt"] as? String,
            let img: String = response["img"] as? String else {
                print("Neccessary fields are missing. Deserialized object:\n \(response)")
                return nil
        }
        
        let comic: NetWebcomic = NetWebcomic()
        
        comic.date = "\(day)-\(month)-\(year)"
        comic.desc = desc
        comic.image = img
        comic.title = title
        
        return comic
    }
    
    private func convert(net: NetWebcomic) -> DBWebcomic {
        let db: DBWebcomic = DBWebcomic(entity: DBWebcomic.entity(), insertInto: AppDelegate.shared?.context)
        
        db.date = self.dateFormatter.date(from: net.date ?? "")
        db.desc = net.desc
        db.image = net.image
        db.title = net.title
        
        return db
    }
    
    private func convert(database: DBWebcomic) -> AppWebcomic {
        let app: AppWebcomic = AppWebcomic()
        
        app.date = database.date
        app.desc = database.desc
        app.image = URL(string: database.image.orDefault)
        app.title = database.title
        
        return app
    }
}
