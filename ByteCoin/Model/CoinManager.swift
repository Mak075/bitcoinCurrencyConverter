//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coinValue: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "32B3D2B4-4189-4D59-8429-EDF09CDF3008"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    func fetchCurrency(currencyName: String) {
        let urlString = "\(baseURL)/\(currencyName)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlStringPar: String) {
            
            //1. Create a URL
            if let url = URL(string: urlStringPar) {
                //2. Create URL session
                let session = URLSession(configuration: .default)
                //3. Give the session a task
                let task = session.dataTask(with: url) { (data, response, error) in
    
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    
                    if let safeData = data {
                        if let bitcoinValue = self.parseJSON(safeData) {
                            self.delegate?.didUpdateCoin(self, coinValue: bitcoinValue)
                        }
                    }
                }
                //4.Start the task
                task.resume()
            }
        }
    
    
    func parseJSON(_ coinData: Data) -> String? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CoinData.self, from: coinData)
                let rateArg = decodedData.rate
                
                var rateString: String {
                    return String(format: "%.2f", rateArg)
                }
                return rateString // vrati vrijednost neku npr 17083.34
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
}
