//
//  CoreDataStorage.swift
//  MonBaluchonParisNYC
//
//  Created by Vincent Caronnet on 05/07/2021.
//

import CoreData

protocol CoreDataStorageProtocol {
    func saveWeather(_ weather: WeatherHTTPData)
    func getWeatherOfCity(id: Int64) -> WeatherHTTPData?
}

enum StorageType {
    case persistent, inMemory
}

class CoreDataStorage: CoreDataStorageProtocol {
    let persistentContainer: NSPersistentContainer
    
    init(_ storageType: StorageType = .persistent) {
        self.persistentContainer = NSPersistentContainer(name: "MonBaluchonParisNYC")
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreDataStore ~> saveContext ~> Error ~>", error.localizedDescription)
            }
        } else {
            print("CoreDataStore ~> saveContext ~> No change to save")
        }
    }
    
    func saveWeather(_ weather: WeatherHTTPData) {
        var cdWeather: CDWeather
        
        if let cityWeather = getCDWeatherOfCity(id: weather.id) {
            cdWeather = cityWeather
        } else {
            cdWeather = CDWeather(context: context)
        }
        
        cdWeather.dt = weather.dt
        cdWeather.timezone = weather.timezone
        cdWeather.icon = weather.weather[0].icon
        cdWeather.weatherDescription = weather.weather[0].description
        cdWeather.id = weather.id
        cdWeather.sunrise = weather.sys.sunrise
        cdWeather.sunset = weather.sys.sunset
        cdWeather.temp = weather.main.temp
        cdWeather.tempMin = weather.main.temp_min
        cdWeather.tempMax = weather.main.temp_max
        
        saveContext()
    }
    func getWeatherOfCity(id: Int64) -> WeatherHTTPData? {
        guard let cdWeather = getCDWeatherOfCity(id: id) else {
            return nil
        }
        
        return WeatherHTTPData(from: cdWeather)
    }
    
    private func getCDWeatherOfCity(id: Int64) -> CDWeather? {
        let fetchRequest: NSFetchRequest<CDWeather> = CDWeather.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        
        guard let fetchResult = try? context.fetch(fetchRequest),
              let cdWeather = fetchResult.first else {
            return nil
        }
        
        return cdWeather
    }
}

extension WeatherHTTPData {
    init?(from cdWeather: CDWeather) {
        self.dt = cdWeather.dt
        self.id = cdWeather.id
        self.timezone = cdWeather.timezone
        
        self.main = Main(
            temp: cdWeather.temp,
            temp_min: cdWeather.tempMin,
            temp_max: cdWeather.tempMax
        )
        
        self.sys = Sys(
            sunrise: cdWeather.sunrise,
            sunset: cdWeather.sunset
        )
        
        guard let icon = cdWeather.icon,
              let description = cdWeather.weatherDescription
        else {
            return nil
        }
        
        self.weather = [
            Weather(
                description: description,
                icon: icon
            )
        ]
    }
}
