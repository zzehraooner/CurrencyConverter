//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Zehra Öner on 26.07.2024.
//

import UIKit

struct ExchangeRateResponse: Codable {
    let result: String
    let conversion_rate: Double
}

class ViewController: UIViewController {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var baseCurrencyTextField: UITextField!
    @IBOutlet weak var targetCurrencyTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func convertButtonTapped(_ sender: Any) {
        guard let amountText = amountTextField.text, let amount = Double(amountText),
                     let baseCurrency = baseCurrencyTextField.text,
                     let targetCurrency = targetCurrencyTextField.text else {
                   resultLabel.text = "Lütfen tüm alanları doldurun"
                   return
    }
        fetchExchangeRate(from: baseCurrency, to: targetCurrency) { rate in
               DispatchQueue.main.async {
                   if let rate = rate {
                       let convertedAmount = amount * rate
                       self.resultLabel.text = "\(amount) \(baseCurrency) = \(convertedAmount) \(targetCurrency)"
                   } else {
                       self.resultLabel.text = "Dönüşüm oranı alınamadı"
                   }
               }
           }
       }

       func fetchExchangeRate(from baseCurrency: String, to targetCurrency: String, completion: @escaping (Double?) -> Void) {
           let apiKey = "856b4dd69ec8c998699b89d1"
           let urlString = "https://v6.exchangerate-api.com/v6/856b4dd69ec8c998699b89d1/pair/USD/EUR"

           guard let url = URL(string: urlString) else {
               print("Geçersiz URL")
               completion(nil)
               return
           }

           let session = URLSession.shared
           let task = session.dataTask(with: url) { (data, response, error) in
               if let error = error {
                   print("Hata oluştu: \(error.localizedDescription)")
                   completion(nil)
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                   print("Geçersiz yanıt")
                   completion(nil)
                   return
               }

               guard let data = data else {
                   print("Veri bulunamadı")
                   completion(nil)
                   return
               }

               do {
                   let exchangeRateResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                   completion(exchangeRateResponse.conversion_rate)
               } catch {
                   print("JSON dönüşüm hatası: \(error.localizedDescription)")
                   completion(nil)
               }
           }

           task.resume()
       }
}

