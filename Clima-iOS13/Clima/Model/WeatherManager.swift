
import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8a57e6af02f0eed8157835f1ac65e7d5&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(latitide: CLLocationDegrees,longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitide)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(cityname: String){
        let urlString = "\(weatherURL)&q=\(cityname)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String){
        //1.create url
        if let url = URL(string: urlString){
            //2.create urlSession
            let session = URLSession(configuration: .default)
            //3.give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4.start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) ->WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature:temp)
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
        
    
}
