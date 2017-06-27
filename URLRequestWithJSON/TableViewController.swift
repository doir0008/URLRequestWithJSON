//
//  TableTableViewController.swift
//  URLRequestWithJSON
//
//  Created by Ryan Doiron on 2016-11-25.
//  Copyright © 2016 doir0008@algonquinlive.com. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var jsonArray: [[String:String]]?

    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // load button is used to make the URLRequest
    @IBAction func loadDataButton(_ sender: Any) {
        // define the url that we want to send to
        let requestUrl: URL = URL(string: "https://lenczes.edumedia.ca/mad9136/a3/respond.php")!
        // create the request object and pass the url
        let myRequest: URLRequest = URLRequest(url: requestUrl)
        // create the URLSession object that will make the request
        let mySession: URLSession = URLSession.shared
        // make the specific task from the session by passing in the request and the function that
        // will be used to handle the request
        let myTask = mySession.dataTask(with: myRequest, completionHandler: requestTask)
        // run the task
        myTask.resume()
        
    }

    // function that will handle the request, receives the data sent back, the error object and handle any errors
    func requestTask (serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        // if the error object has been set then an error occurred
        if serverError != nil {
            // send an empty string as the data and the error to the callback func
            self.myCallback(responseString: "", error: serverError?.localizedDescription)
        } else {
            // if no error, stringify the data and send it to the callback func
            let result = NSString(data: serverData!, encoding: String.Encoding.utf8.rawValue)!
            self.myCallback(responseString: result as String, error: nil)
        }
    }
    
    // callback func to be triggered when response is received
    func myCallback (responseString: String, error: String?) {
        // if the server request generated an error then we handle it
        if error != nil {
            print("ERROR is " + error!)
        } else {
            // else we process the data and encapsulate it in the array
            print("DATA is " + responseString)
            if let myData: Data = responseString.data(using: .utf8) {
                do {
                    jsonArray = try JSONSerialization.jsonObject(with: myData, options: []) as? [[String:String]]
                } catch let convertError {
                    print(convertError.localizedDescription)
                }
            }
        }
        // update the table data - this must be done because the callback runs on a secondary thread
        // only the main thread can update the UI and DispatchQueue method will do that
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }

    // return the array count as numberOfRows else return 0
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arr = jsonArray {
            return arr.count
        } else {
            return 0
        }
    }

    // Set the cell.text to the data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        if let arr = jsonArray {
            let thisDictionary = arr[indexPath.row]
            cell.textLabel?.text = thisDictionary["name"]! + " " + thisDictionary["email"]!
            return cell
        }
        return cell
    }
}
