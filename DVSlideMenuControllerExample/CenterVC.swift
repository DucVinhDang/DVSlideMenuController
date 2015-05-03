//
//  CenterVC.swift
//  DVSlideMenuControllerExample
//
//  Created by Đặng Vinh on 3/23/15.
//  Copyright (c) 2015 DVISoft. All rights reserved.
//

import UIKit

class CenterVC: UIViewController, DVSlideMenuControllerDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Center View"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftToggleButtonWithImage(imageName: "MenuIcon")
        self.addRightToggleButtonWithImage(imageName: "MenuIcon")
        // Do any additional setup after loading the view.
        dvSlideMenuController()?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleLeftAction(sender: AnyObject) {
        toggleLeftPanel()
    }

    @IBAction func toggleRightAction(sender: AnyObject) {
        toggleRightPanel()
    }
    
    @IBAction func newViewAction(sender: AnyObject) {
        let detailCenterVC = DetailCenterVC(nibName: "DetailCenterVC", bundle: nil)
    self.navigationController?.pushViewController(detailCenterVC, animated: true)
    }
    
    
    // DVSlideMenuControllerDelegate Methods
    
    func dvSlideMenuControllerWillShowLeftPanel() {
        println("Will show left panel")
    }
    
    func dvSlideMenuControllerDidShowLeftPanel() {
        println("Did show left panel")
    }
    
    func dvSlideMenuControllerWillHideLeftPanel() {
        println("Will hide left panel")
    }
    
    func dvSlideMenuControllerDidHideLeftPanel() {
        println("Did hide left panel")
    }
    
    func dvSlideMenuControllerWillShowRightPanel() {
        println("Will show right panel")
    }
    
    func dvSlideMenuControllerDidShowRightPanel() {
        println("Did show right panel")
    }
    
    func dvSlideMenuControllerWillHideRightPanel() {
        println("Will hide right panel")
    }
    
    func dvSlideMenuControllerDidHideRightPanel() {
        println("Did hide right panel")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
