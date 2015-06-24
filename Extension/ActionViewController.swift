//
//  ActionViewController.swift
//  Extension
//
//  Created by Henry on 6/23/15.
//  Copyright (c) 2015 Henry. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make that call done()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        //let us control how it interacts with the parent app, and this will be an array of data the parent app is sending to our extension to use
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            //pulls out the first attachment from the first input item
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                //ask the item provider to actually provide us with its item
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options:
                    nil) { [unowned self] (dict, error) in
                        //get a dictionary of data that contains all the information
                        let itemDictionary = dict as! NSDictionary
                        // the data sent from JavaScript, and stored in a special key 
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                        
                        self.pageTitle = javaScriptValues["title"] as! String
                        self.pageURL = javaScriptValues["URL"] as! String
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            //set the view controller's title property on the main queue
                            self.title = self.pageTitle
                        }
                 }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        //new NSExtensionItem object that will host our items
        let item = NSExtensionItem()
        //a dictionary containing the key "customJavaScript" and the value of the textView
        //Put that dictionary into another dictionary
        let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": textView.text]]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext!.completeRequestReturningItems([item], completionHandler: nil)
    }

}
