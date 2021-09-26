//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = SentimentClassifier()
    
    let swifter = Swifter(consumerKey: "5qNoo4TanWrN33pWJkoi032Hz", consumerSecret: "76YQ0QUA15EIyz8G5st3dIjRVCGQPUjaVG8npxIIEyHweSqM3H")

    let tweetCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                //print(results)
                
                var tweets = [SentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        tweets.append(SentimentClassifierInput(text: tweet))
                    }
                }
                
                self.makePredictions(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter api request \(error)")
            }
        }
    }
    
    func makePredictions(with tweets: [SentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with : sentimentScore)
            
        } catch {
            print(error)
        }
    }
    
    func updateUI(with sentimentScore: Int) {
        switch sentimentScore {
        case 20... :
            self.sentimentLabel.text = "😍"
        case 10... :
            self.sentimentLabel.text = "😃"
        case 0... :
            self.sentimentLabel.text = "🙂"
        case 0:
            self.sentimentLabel.text = "😐"
        case (-10)... :
            self.sentimentLabel.text = "😕"
        case (-20)... :
            self.sentimentLabel.text = "😡"
        default:
            self.sentimentLabel.text = "🤮"
        }
    }
    
}

