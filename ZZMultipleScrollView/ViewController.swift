//
//  ViewController.swift
//  ZZMultipleScrollView
//
//  Created by zerry on 2021/4/27.
//

import UIKit

class ViewController: UIViewController {
    var count = 30
    var footerTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let headerLabelView = UIView.init()
        headerLabelView.backgroundColor = .darkGray
        let label = UILabel()
        label.text = "123"
        headerLabelView.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.left.right.top.bottom.equalToSuperview()
            m.height.equalTo(200).priority(.high)
        }
        
        let contentView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        contentView.backgroundColor = .gray
        contentView.delegate = self
        contentView.dataSource = self
        self.footerTableView = contentView
        
        let headerView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = .gray
        headerView.delegate = self
        headerView.dataSource = self
                
        let footerLabel = UILabel(frame: .init(x: 0, y: 0, width: width, height: 200))
        footerLabel.text = "123"
        
        let view = ZZTwoMultipleScrollView.init(frame: self.view.bounds,
                                             sectionView: sectionView,
                                             headerView: headerLabelView,
                                             footerView: contentView)
        view.hasRefresFooter = true
        view.hasRefreshHeader = true
        view.kDelegate = self
        self.view.addSubview(view)
        
        view.snp.makeConstraints { (m) in
            m.bottom.trailing.leading.equalToSuperview()
            m.top.equalToSuperview().offset(88)
        }
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
        
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    
}

extension ViewController: ZZTwoMultipleScrollViewDelegte{
    func twoMultipleScrollViewRefreshFooter(_ multipleScrollView: ZZTwoMultipleScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.count += 30
            self.footerTableView.reloadData()
            multipleScrollView.endRefreshFooter()
        }
    }
    
    func twoMultipleScrollViewRefreshHeader(_ multipleScrollView: ZZTwoMultipleScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.count = 30
            self.footerTableView.reloadData()
            multipleScrollView.endRefreshHeader()
        }
    }
}

