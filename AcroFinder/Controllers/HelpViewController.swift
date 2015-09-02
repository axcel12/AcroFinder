//
//  HelpViewController.swift
//  AcroFinder
//
//  Created by AcroFinder Team on 4/29/2015.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet var helpTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help"
        // Do any additional setup after loading the view.
        helpTextView.scrollRangeToVisible(NSMakeRange(0,0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
