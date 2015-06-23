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

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let us control how it interacts with the parent app, and this will be an array of data the parent app is sending to our extension to use
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            //pulls out the first attachment from the first input item
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                //ask the item provider to actually provide us with its item
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options:
                    nil) { [unowned self] (dict, error) in
                    //do stuff
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
