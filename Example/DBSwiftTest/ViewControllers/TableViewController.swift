//
//  UITableViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import Foundation

class TableViewController : UITableViewController {

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	func didDeleteItemAtIndexPath(indexPath: NSIndexPath) {
		self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
		self.tableView.setEditing(false, animated: true)
		self.performBlockAfterDelay(0.4, block: self.tableView.reloadData)
	}
}