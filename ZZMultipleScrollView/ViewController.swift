//
//  ViewController.swift
//  MultipleScrollView
//
//  Created by zerry on 2021/4/27.
//

import UIKit

class ViewController: UIViewController {
    var count = 2
    var footerTableView: UITableView!
    var scrollView : TwoScrollView?
    var headerView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TwoScrollView"
        
        let width = self.view.frame.width
        let height = self.view.frame.height

        let sectionView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 44))
        sectionView.backgroundColor = .red
        let label1 = UILabel()
        label1.text = "123"
        sectionView.addSubview(label1)
        label1.snp.makeConstraints { (m) in
            m.left.right.top.bottom.equalToSuperview()
            m.height.equalTo(100).priority(.high)
        }
        
        let contentView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = .gray
        contentView.delegate = self
        contentView.tag = 1
        contentView.dataSource = self
        contentView.estimatedRowHeight = 44
        self.footerTableView = contentView
        
        let headerView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = .gray
        headerView.delegate = self
        headerView.estimatedRowHeight = 44
        headerView.dataSource = self
        headerView.tag = 1
        let headerViewFooterView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 44))
        let button = UIButton()
        headerViewFooterView.addSubview(button)
        button.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
        button.setTitle("更多", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(headerViewAddMore), for: .touchUpInside)
        headerView.tableFooterView = headerViewFooterView
        self.headerView = headerView
        
        let footerLabel = UILabel(frame: .init(x: 0, y: 0, width: width, height: 200))
        footerLabel.text = "123"
        
        let view = TwoScrollView.init(frame: self.view.bounds,
                                             sectionView: sectionView,
                                             headerView: headerView,
                                             footerView: contentView)
        view.hasRefresFooter = true
        view.hasRefreshHeader = true
        view.kDelegate = self
        self.view.addSubview(view)
        self.scrollView = view
        
        view.snp.makeConstraints { (m) in
            m.bottom.trailing.leading.equalToSuperview()
            m.top.equalToSuperview().offset(88)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "More", style: .done, target: self, action: #selector(more))
    }
    
    @objc
    func headerViewAddMore() {
        self.count += 2
        self.headerView.reloadData()
        self.scrollView?.reloadHeaderView()
        self.scrollView?.endRefreshHeader()
    }
    
    @objc
    func more() {
//        self.headerView.frame.size.height = 100
//        self.scrollView?.reload()
        self.navigationController?.pushViewController(MoreViewController(), animated: true)
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "1234")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "1234")
        }
        
        cell?.textLabel?.text = "\(tableView.tag): \(indexPath.section)\(indexPath.row)"
        return cell!
    }
    
}

extension ViewController: TwoScrollViewDelegte{
    func twoScrollViewRefreshFooter(_ multipleScrollView: TwoScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.count += 2
            self.footerTableView.reloadData()
            multipleScrollView.reloadFooterView()
            multipleScrollView.endRefreshFooter()
        }
    }
    
    func twoScrollViewRefreshHeader(_ multipleScrollView: TwoScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.count = 2
            self.footerTableView.reloadData()
            multipleScrollView.reloadHeaderView()
            multipleScrollView.endRefreshHeader()
        }
    }
}

