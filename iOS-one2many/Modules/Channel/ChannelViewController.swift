//  
//  ChannelViewController.swift
//  one-to-many-call
//
//  Created by usama farooq on 13/06/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
import MMWormhole
import iOSSDKStreaming

public class ChannelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var blurView: UIView!
    
    lazy var refreshControl = UIRefreshControl()
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP, optionalDirectory: "wormhole")

    var viewModel: ChannelViewModel!
    private var selectedGroupId: Int? = nil
    let navigationTitle = UILabel()
    
    
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
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewModelWillDisappear()
    }
    
    @IBAction func didTapReferesh(_ sender: UIButton) {
        viewModel.fetchGroups()
    }
    
    @IBAction func didTapNewChat(_ sender: UIButton) {
        didTappedAdd()
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "UserResponse")
        viewModel.logout()
        let viewController = LoginBuilder().build(with: self.navigationController)
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            case .showProgress:
                    ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .reload:
                self.refreshControl.endRefreshing()
                tableView(isHidden: viewModel.groups.count > 0 ? false : true)
                tableView.reloadData()
            case .connected:
               break
            case .disconnected:
               break
            case .failure(let message):
                ProgressHud.showError(message: message, viewController: self)
            case .update(let row):
                let index = IndexPath(row: row, section: 0)
                tableView.reloadRows(at: [index], with: .automatic)
            }
        }
    }
    
}

extension ChannelViewController {
    func configureAppearance() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        tableView(isHidden: viewModel.groups.count > 0 ? false : true)
        configureEmptyView()
        navigationTitle.text = "Chat Rooms"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        let image = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(didTappedAdd)
        )
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        configureNavigationView()
    }
    
    
    private func configureNavigationView() {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
    }
    
    @objc func didTapBackButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func refresh() {
        viewModel.fetchGroups()
    }
    
    @objc func didTappedAdd() {
       
        let vc = CreateGroupBuilder()
            .build(with: self.navigationController, delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureEmptyView() {
        
        titleLabel.textColor = .appDarkGreenColor
        titleLabel.font = UIFont(name: "Inter-Regular", size: 21)
        subTitle.textColor = .appLightIndigoColor
        subTitle.font = UIFont(name: "Poppins-Regular", size: 14)
       
    }
    private func tableView(isHidden: Bool) {
        if isHidden {
            tableView.isHidden = isHidden
            emptyView.isHidden = !isHidden
        } else {
            tableView.isHidden = isHidden
            emptyView.isHidden = !isHidden
        }
        
    }
}

extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isSearching {
            return viewModel.searchGroup.count
        }
        return viewModel.groups.count

    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.selectionStyle = .none
        let item = viewModel.itemAt(row: indexPath.row)
        cell.configure(with: item.group, broadcastData: item.broadCastData, delegate: self, isSelected: viewModel.check(id: item.group.id))
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = viewModel.groups[indexPath.row]
        viewModel.groupSelection(group: group, row: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal,
                                         title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.selectedGroupId = indexPath.row
            self?.loadGroupView()
                                            completionHandler(true)
        }
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.viewModel.deleteGroup(with: indexPath.row)
                                        completionHandler(true)
        }
        if viewModel.groups[indexPath.row].participants.count <= 2 {
            let configuration = UISwipeActionsConfiguration(actions: [trash])
            return configuration
        }
        let configuration = UISwipeActionsConfiguration(actions: [edit, trash])
        return configuration
    }

}

extension ChannelViewController: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.isSearching = true
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension ChannelViewController: GroupCallDelegate {
    func didTapScreen(group: Group, broadcastData: BroadcastData) {
        
    }
    
    func didTapVideo(group: Group) {
        viewModel.moveToVideo(group: group)
    }
  
}

extension ChannelViewController: CreateGroupDelegate {
    func didGroupCreated(group: Group) {
        viewModel.groups.insert(group, at: 0)
        tableView.reloadData()
    }
    
}

extension ChannelViewController {
    func loadGroupView() {
        let vc = CreateGroupPopup()
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        vc.delegate = self
        blurView.isHidden = false
    }
}

extension ChannelViewController: PopupDelegate {
    func didTapDismiss(groupName: String?) {
        guard let id = selectedGroupId, let name = groupName else {return}
        blurView.isHidden = true
        viewModel.editGroup(with: name, id: id)
    }
    
}
