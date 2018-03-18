//
//  SettingsViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-03-30.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//
import UIKit

class SettingsViewController : UITableViewController {

    init(sections: [String], rows: [String: [Setting]]) {
        self.sections = sections
        if UserDefaults.isTouchIdEnabled {
            self.rows = rows
        } else {
            var tempRows = rows
            tempRows["Manage"] = tempRows["Manage"]?.filter { $0.title != S.Settings.touchIdLimit }
            self.rows = tempRows
        }
        super.init(style: .plain)
    }

    private let sections: [String]
    private let rows: [String: [Setting]]
    private let cellIdentifier = "CellIdentifier"
    private let titleLabel = UILabel(font: .customBold(size: 26.0), color: .darkText)

    override func viewDidLoad() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48.0))
        headerView.backgroundColor = .whiteTint
        headerView.addSubview(titleLabel)
        titleLabel.constrain(toSuperviewEdges: UIEdgeInsetsMake(0, C.padding[2], 0, 0))
        titleLabel.text = S.Settings.title

        tableView.register(SeparatorCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .whiteTint

        addCloseNavigationItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var indexPaths: [IndexPath] = []
        sections.enumerated().forEach { i, key in
            rows[key]?.enumerated().forEach { j, setting in
                if setting.accessoryText != nil {
                    indexPaths.append(IndexPath(row: j, section: i))
                }
            }
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[sections[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
            cell.textLabel?.text = setting.title
            cell.textLabel?.font = .customBody(size: 16.0)
            cell.textLabel?.textColor = .darkText

            let label = UILabel(font: .customMedium(size: 14.0), color: .grayTextTint)
            label.text = setting.accessoryText?()
            label.sizeToFit()
            cell.accessoryView = label
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        view.backgroundColor = .whiteTint
        let label = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
        view.addSubview(label)
        label.text = sections[section]

        let separator = UIView()
        separator.backgroundColor = .secondaryShadow
        view.addSubview(separator)
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])

        label.constrain([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -4.0) ])

        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
            setting.callback()
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
