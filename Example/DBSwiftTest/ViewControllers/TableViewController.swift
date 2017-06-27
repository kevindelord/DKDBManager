//
//  UITableViewController.swift
//  DBSwiftTest
//
//  Created by kevin delord on 22/01/16.
//  Copyright © 2016 Smart Mobile Factory. All rights reserved.
//

import UIKit
import Foundation

class TableViewController : UITableViewController {

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	func didDeleteItemAtIndexPath(_ indexPath: IndexPath) {
		self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
		self.tableView.setEditing(false, animated: true)
		self.performBlock(afterDelay: 0.4, block: self.tableView.reloadData)
	}
}
