//
//  StartViewController.swift
//  Armoir
//
//  Created by Cisco Vlahakis on 12/5/18.
//  Copyright © 2018 CS147. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    /*override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }*/
    
    @IBAction func continueButton(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "\"Facebook\" Would Like to Access Your Contacts", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
            self.present(mainVC!, animated: true, completion: nil)
        }
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .cancel, handler: nil))
        alert.addAction(yes)
        alert.view.tintColor = UIColor.blue
        self.present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
