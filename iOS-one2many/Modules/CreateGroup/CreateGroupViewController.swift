//  
//  CreateGroupViewController.swift
//  one-to-many-call
//
//  Created by usama farooq on 14/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit



public class CreateGroupViewController: UIViewController {

    
    var viewModel: CreateGroupViewModel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    let navigationTitle = UILabel()
    lazy var refreshControl = UIRefreshControl()
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            case .showProgress:
                ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .failure(message: let message):
                ProgressHud.showError(message: message, viewController: self)
            case .updateRow(index: let index):
                let selectedIndexPath = IndexPath(item:index , section: 0)
                self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
            case .reload:
                self.refreshControl.endRefreshing()
                tableView.reloadData()
            case .groupCreated(group: let group):
                viewModel.delegate?.didGroupCreated(group: group)
                self.navigationController?.popToRootViewController(animated: true)
            default:
                break
            }
        }
    }
    
    func moveToChat(group: Group, isExist: Bool) {

    }
    
}

extension CreateGroupViewController {
    func configureAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.register(UINib(nibName: "CreateGroupCell", bundle: nil), forCellReuseIdentifier: "CreateGroupCell")
        configureNavigation()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
   }
            
   @objc func refresh() {
       viewModel.reloadUsers()
   }
    
    private func configureNavigation() {
        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysOriginal)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(didTappedAdd)
        )
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        navigationTitle.text = "Create Group Chat"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
    }
    
    @objc func didTappedAdd() {
            let vc = CreateGroupPopup()
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
            vc.delegate = self
            blurView.isHidden = false

    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateGroupViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateGroupCell", for: indexPath) as! CreateGroupCell
        let item = viewModel.viewModelItem(row: indexPath.row)
        cell.configure(with: item, selected: viewModel.check(id: item.userID))
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = viewModel.viewModelItem(row: indexPath.row)
        viewModel.addUser(userId: user.userID, row: indexPath.row)

    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: Int = 0
        if viewModel.searchContacts.count > 0
        {
                self.tableView.backgroundView = nil
                numOfSection = 1
             }
             else
             {
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
                noDataLabel.text = "No User Found"
                noDataLabel.textColor = .appDarkColor
                noDataLabel.textAlignment = NSTextAlignment.center
                self.tableView.backgroundView = noDataLabel

              }

            return numOfSection
    }
    
    
}

extension CreateGroupViewController: PopupDelegate {
    func didTapDismiss(groupName: String?) {
        
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
        guard let title = groupName else {return }
        viewModel.createGroup(with: title)
    }
    
    func didTapDismiss() {
       
    }
}

extension CreateGroupViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        viewModel.isSearching = true
        viewModel.filterGroups(with: text)
        print(text)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
