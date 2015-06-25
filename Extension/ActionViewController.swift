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
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        //four parameters: the object that should receive notifications, the method that should be called, the notification we want to receive, and the object we want to watch
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
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
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        //telling us the frame of the keyboard after it has finished animating
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        //need to convert the rectangle to our view's co-ordinates
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            textView.contentInset = UIEdgeInsetsZero
        } else {
            //setting the inset of a text view
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        //make the text view scroll so that the text entry cursor is visible
        textView.scrollRangeToVisible(selectedRange)
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
