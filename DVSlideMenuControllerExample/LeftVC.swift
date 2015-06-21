//
//  LeftVC.swift
//  DVSlideMenuControllerExample
//
//  Created by Đặng Vinh on 3/23/15.
//  Copyright (c) 2015 DVISoft. All rights reserved.
//

import UIKit

class LeftVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    let array = ["Push new viewcontroller", "Change the center view", "Hide panel", "Change to the old center view"]
    let detailArray = ["Create a new view controller and push it by navigation controller", "Change the current center view to a new view then hide panel", "Just hide this panel", "Change to the first center view when we start the simulator"]

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Left View"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
//        self.tableView.backgroundColor = UIColor(red: 0.945, green: 0.945, blue: 0.945, alpha: 1)
        self.tableView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = array[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = detailArray[indexPath.row]
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.numberOfLines = 3
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.row) {
        case 0:
            let newCenterVC = NewCenterVC(nibName: "NewCenterVC", bundle: nil)
            self.navigationController?.pushViewController(newCenterVC, animated: true)
        case 1:
            let newCenterVC = NewCenterVC(nibName: "NewCenterVC", bundle: nil)
            let navNewCenter = UINavigationController(rootViewController: newCenterVC)
            newCenterVC.addLeftToggleButtonWithTitle(title: "Left")
            newCenterVC.addRightToggleButtonWithTitle(title: "Right")
            dvSlideMenuController()?.setTheCenterViewController(navNewCenter)
            hideThisPanel()
        case 2:
            hideThisPanel()
        case 3:
            let centerVC = CenterVC(nibName: "CenterVC", bundle: nil)
            let navCenter = UINavigationController(rootViewController: centerVC)
            dvSlideMenuController()?.setTheCenterViewController(navCenter)
            hideThisPanel()
        default:
            break;
        }
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
