//
//  CacheFilesListController.swift
//  Zhangzhilicai
//
//  Created by william on 10/11/2017.
//  Copyright © 2017 william. All rights reserved.
//

import UIKit
#if TestTool
class CacheFilesListController: UITableViewController {
    var files: [URL]!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "缓存文件"

        files = WKZCache.shared.files()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let file = self.files[indexPath.row]
        cell.textLabel?.text = file.lastPathComponent
        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let file = self.files[indexPath.row]
        if file.pathExtension == "png" || file.pathExtension == "jpg" {
            let image = UIImage(contentsOfFile: file.path)!
            let controller = ZZImagePreviewController(photos: [image], currentIndex: 0)
            self.showController(controller)
        }
    }
}
#endif
