//
//  MoreViewController.swift
//  ZZMultipleScrollView
//
//  Created by zerry on 2021/4/28.
//

import UIKit

class MoreViewController: UIViewController {
    lazy var subTableView0: UITableView = {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let tableView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        tableView.backgroundColor = .gray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = 0
        return tableView
    }()
    lazy var subTableView1: UITableView = {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let tableView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = 1
        return tableView
    }()
    lazy var subTableView2: UITableView = {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let tableView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        tableView.backgroundColor = .gray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = 2
        return tableView
    }()
    lazy var subTableView3: UITableView = {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let tableView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = 3
        return tableView
    }()
    
    func getHeaderView() -> UIView {
        
        let view = UIView.init(frame: .init(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .white
        
        let label = UILabel.init()
        label.text = "2017年10月31日 iOS里当手势和tableview的点击方法重叠的时候,会默认执行手势方法,tableview的方法会被拦截掉,所以我们要在手势的代理方法里面做一下判断,当touch的view是我们需要触发的view的时候..."
        label.numberOfLines = 0
        view.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MoreScrollView"

        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let multipleScrollView = MultipleScrollView.init(frame: .init(x: 0, y: 88, width: width, height: height - 88))
        multipleScrollView.dataSource = self
        multipleScrollView.delegate = self
        multipleScrollView.tag = 1
        
//        let tableHeaderView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 200))
//        tableHeaderView.backgroundColor = .red
//        multipleScrollView.tableView.tableHeaderView = tableHeaderView
        self.view.addSubview(multipleScrollView)
    }
}

extension MoreViewController: MultipleScrollViewDelegate, MultipleScrollViewDataSource{
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfScrollSections(in multipleScrollView: MultipleScrollView) -> Int {
        return 4
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, viewForRowAt indexPath: IndexPath) -> UIView {
        if indexPath.section == 0 {
            return subTableView0
        } else if indexPath.section == 1{
            return subTableView1
        } else if indexPath.section == 2{
            return subTableView2
        } else if indexPath.section == 3{
            return subTableView3
        }
        return UIView()
    }
    
    func multipleScrollView(_ multipleScrollView: MultipleScrollView, viewForHeaderInSection section: Int) -> UIView? {
        // 没有循环利用
        return section == 0 ? nil : getHeaderView()
    }
    
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "1234")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "1234")
            cell?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGestureRecognizer)))
        }
        
        cell?.textLabel?.text = "\(tableView.tag)       \(indexPath.section)\(indexPath.row)"
        
        return cell!
    }
    
    @objc
    func tapGestureRecognizer() {
        print("123")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(tableView.tag)       \(indexPath.section)\(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section)"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
}
