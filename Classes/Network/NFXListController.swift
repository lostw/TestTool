//
//  NFXListController.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//
#if TestTool
import Foundation

class NFXListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate {

    var tableView: UITableView = UITableView()
    var searchController: UISearchController!

    var list = [NFXHTTPModel]()
    var filteredList = [NFXHTTPModel]()
    var sourceList: [NFXHTTPModel] {
        return self.searchController.isActive ? self.filteredList : self.list
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "网络日志"
        self.edgesForExtendedLayout = []
//        self.extendedLayoutIncludesOpaqueBars = true
//        self.automaticallyAdjustsScrollViewInsets = false

        self.tableView.frame = self.view.frame
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = 58
        self.view.addSubview(self.tableView)

        self.tableView.register(NFXListCell.self, forCellReuseIdentifier: String(describing: NFXListCell.self))

        let rightButtons = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(NFXListController.trashButtonPressed)),
            UIBarButtonItem(title: "统计", style: .plain, target: self, action: #selector(NFXListController.settingsButtonPressed))
        ]

        self.navigationItem.rightBarButtonItems = rightButtons

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.scopeButtonTitles = ["All", "JSON", "HTML", "XML", "IMAGE", "OTHER"]
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
//        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.definesPresentationContext = true
//        self.searchController.searchBar.autoresizingMask = [.flexibleWidth]
//        self.searchController.searchBar.backgroundColor = theme[.major]
//        self.searchController.searchBar.barTintColor = theme[.major]
//        self.searchController.searchBar.tintColor = .white
//        self.searchController.searchBar.isTranslucent = false
//        self.searchController.searchBar.searchBarStyle = .minimal
//        self.searchController.view.backgroundColor = .white
//        self.searchController.searchBar.delegate = self

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NFXListController.reloadTableViewData),
            name: NSNotification.Name.NFXReloadData,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NFXListController.deactivateSearchController),
            name: NSNotification.Name.NFXDeactivateSearch,
            object: nil)

        self.list = NFXHTTPModelManager.shared.getModels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableViewData()
    }

    @objc func settingsButtonPressed() {
        let settingsController = NFXStatisticsController()
        self.navigationController?.pushViewController(settingsController, animated: true)
    }

    @objc func trashButtonPressed() {
        let actionSheetController = UIAlertController(title: "Clear data?", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        actionSheetController.addAction(cancelAction)
        let yesAction = UIAlertAction(title: "确定", style: .default) { _ in
            NFX.shared.clearOldData()
            self.tableView.reloadData()
        }
        actionSheetController.addAction(yesAction)

        self.present(actionSheetController, animated: true, completion: nil)
    }

    @objc func deactivateSearchController() {
        self.searchController.isActive = false
    }

    @objc func reloadTableViewData() {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sourceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: String(describing: NFXListCell.self), for: indexPath) as! NFXListCell

        let obj = self.sourceList[indexPath.row]
        cell.configForObject(obj)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.sourceList[indexPath.row]
        let detailsController = NFXDetailsController()
        detailsController.selectedModel = model
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
}

extension NFXListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.filterResult(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension NFXListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        self.filterResult(searchController.searchBar.text!, scope: scope)
        reloadTableViewData()
    }

    func filterResult(_ searchText: String, scope: String) {
        var filter: ((NFXHTTPModel) -> Bool)!
        if scope != "All" {
            filter = { model in
                return model.responseType == scope && model.requestURL!.ranges(of: searchText, options: .caseInsensitive) != nil
            }
        } else {
            filter = { model in
                return model.requestURL!.ranges(of: searchText, options: .caseInsensitive) != nil
            }
        }

        self.filteredList = self.list.filter(filter)
    }
}

#endif
