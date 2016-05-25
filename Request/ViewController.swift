//
//  ViewController.swift
//  Request
//
//  Created by 成沢淳史 on 3/13/16.
//  Copyright © 2016 成沢淳史. All rights reserved.
//

import Cocoa
import Foundation
import Darwin

class Request {
    var url : NSURL!
    var request : NSMutableURLRequest!
    var return_data : NSString?
    
    
    init(url : NSURL) {
        self.url = url
        self.request = NSMutableURLRequest(URL: url)
    }
    
    func get() {
        request.HTTPMethod = "GET"
    }
    
    func get(params : Dictionary<String, String>) {
        request.HTTPMethod = "GET"
        url_with_params(params)
        print(self.url)

    }
    
    func post(files : Dictionary<String, NSData>) {
        request.HTTPMethod = "POST"
        let boundary  = randomStringWithLength(29)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = dataWithDictionary(files, boundary: boundary as String)
        request.HTTPBody = data

    }   
    
    func post(params : Dictionary<String, String>, files : Dictionary<String, NSData>) {
        request.HTTPMethod = "POST"
        url_with_params(params)
        request.HTTPMethod = "POST"
        let boundary  = randomStringWithLength(29)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = dataWithDictionary(files, boundary: boundary as String)
        request.HTTPBody = data
    }
    
    func url_with_params(params: Dictionary<String, String>) {
        var base = self.url.absoluteString
        base = base + "?"
        var i = 0
        for (key, val) in params {
            i = i + 1
            base = "\(base)\(key)=\(val)"
            if (i == params.count) {
                break
            } else {
                base = base + "&"
            }
        }
        self.url = NSURL(string: base)!
        self.request = NSMutableURLRequest(URL: self.url)
    }
    
          
    
    //Dictionary から http の body を生成します
    func dataWithDictionary(files : NSDictionary?, boundary: String?) -> NSData? {
        let data = NSMutableData()
        var i = 0
        data.appendData(str2data("--\(boundary!)\n"))
        for (key, val) in files! {
            i = i+1
            data.appendData( str2data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\n\n") )
            data.appendData(val as! NSData)
            data.appendData(str2data("\n"))
            if files!.count != i {
                data.appendData(str2data("--\(boundary!)\n"))
            } else {
                data.appendData(str2data("--\(boundary!)"))
                break
            }
        }
        data.appendData(str2data("--\n"))
        return data
    }
    
    // String -> NSData
    func str2data(str : String) -> NSData {
        return NSString(string: str).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    // ランダムな文字列を獲得します
    func randomStringWithLength (len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    
    
}

class ViewController: NSViewController {
    @IBOutlet weak var textarea : NSTextField?
    
    var req : Request!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the .
        req = Request(url: NSURL(string: "http:localhost:8000")!)

     }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // GET 
    @IBAction func onGet(sender: AnyObject) {
        let params : Dictionary<String, String> = Dictionary(dictionaryLiteral: ("key1", "apple"), ("key2", "banana"))
        req.get(params)
        let session : NSURLSession! = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(req.request, completionHandler: { (data, response, err) in
            let statusCode : Int? = (response as? NSHTTPURLResponse)?.statusCode
            self.showContent(statusCode!, data: data!)
        })
        task.resume()
    }
    
    // POST
    @IBAction func onPost(sender: AnyObject) {
        let str = "hello"
        let datum = str.dataUsingEncoding(NSUTF8StringEncoding)!
        let files = Dictionary(dictionaryLiteral: ("sample", datum), ("image", datum))
        req.post(files)
        let session : NSURLSession! = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(req.request, completionHandler: { (data, response, err) in
            let statusCode : Int? = (response as? NSHTTPURLResponse)?.statusCode
            self.showContent(statusCode!, data: data!)
        })
        task.resume()
        
    }
    
    // show response from server
    func showContent(statusCode: Int, data: NSData) {
        if(statusCode == 200) {
            let content = NSString(data: data, encoding: NSUTF8StringEncoding)
            self.textarea?.stringValue = content as! String
        } else {
            let return_message = "HTTP : \(statusCode)"
            self.textarea?.stringValue = return_message
        }
    }

    @IBAction func onExit(sender: NSButton) {
        exit(0)
    }

}

