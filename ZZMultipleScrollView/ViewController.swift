//
//  ViewController.swift
//  MultipleScrollView
//
//  Created by zerry on 2021/4/27.
//

import UIKit

class ViewController: UIViewController {
    var headerCount = 20
    var footerCount = 20
    
    var scrollView : TwoScrollView?
    var footerView: UITableView!
    var headerView : UITableView!
    
    var width : CGFloat = 0
    var height : CGFloat = 0
    var rowHeight : CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "TwoScrollView"
        width = self.view.frame.width
        height = 724
        
        let sectionView0 = createSectionView()
        let sectionView1 = createSectionView()
        
        let footerView = creatTableView(tag: 1)
        self.footerView = footerView
        
        let headerView = creatTableView(tag: 0)
        self.headerView = headerView
        
        let footerLabel = UILabel(frame: .init(x: 0, y: 0, width: width, height: 200))
        footerLabel.text = "123"
        
        let view = TwoScrollView.init(frame: self.view.bounds,
                                      headerSectionView: sectionView0,
                                      headerView: headerView,
                                      footerSectionView: sectionView1,
                                      footerView: footerView)
        
        view.hasRefresFooter = true
        view.hasRefreshHeader = true
        view.kDelegate = self
        self.view.addSubview(view)
        self.scrollView = view
        
        let tableHeaderView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 150))
        tableHeaderView.backgroundColor = .lightGray
        view.tableView.tableHeaderView = tableHeaderView
        
        view.snp.makeConstraints { (m) in
            m.bottom.trailing.leading.equalToSuperview()
            m.top.equalToSuperview().offset(88)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "NextPage", style: .done, target: self, action: #selector(nextPage))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Refresh", style: .done, target: self, action: #selector(refresh))
    }
    
    func createSectionView() -> UIView{
       let sectionView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 44))
       sectionView.backgroundColor = .red
       let label1 = UILabel()
       label1.text = "123"
       sectionView.addSubview(label1)
       label1.snp.makeConstraints { (m) in
           m.left.right.top.bottom.equalToSuperview()
           m.height.equalTo(88).priority(.high)
       }
        return sectionView
    }
    
    func creatTableView(tag: Int) -> UITableView{
        
        let headerView = UITableView.init(frame: .init(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = .gray
        headerView.delegate = self
        headerView.estimatedRowHeight = rowHeight
        headerView.dataSource = self
        headerView.tag = tag
        
        let headerViewFooterView = UIView.init(frame: .init(x: 0, y: 0, width: width, height: 44))
        let button = UIButton()
        headerViewFooterView.addSubview(button)
        button.tag = tag
        button.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
        button.setTitle("More", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(self, action: #selector(addMore), for: .touchUpInside)
        headerView.tableFooterView = headerViewFooterView
        return headerView
    }
    
    @objc
    func addMore(_ button: UIButton) {
        let addCount = 5
        let addHeight: CGFloat = rowHeight * CGFloat(addCount)
        if button.tag == 0 {
            
            headerCount += addCount
            headerView.reloadData()
            
            scrollView?.reloadHeaderView(height: addHeight)
        } else {
            footerCount += addCount
            footerView.reloadData()
            scrollView?.reloadFooterView()
        }
    }
    
    @objc
    func nextPage() {
        //        self.headerView.frame.size.height = 100
        //        self.scrollView?.reload()
        self.navigationController?.pushViewController(MoreViewController(), animated: true)
    }
    
    @objc
    func refresh() {
        self.headerCount = 5
        self.footerCount = 5
        self.headerView.reloadData()
        self.footerView.reloadData()
        
        self.scrollView?.reloadHeaderView()
        self.scrollView?.reloadFooterView()
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == headerView ? headerCount : footerCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "1234")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "1234")
        }
        
        cell?.textLabel?.text = "\(tableView.tag): \(indexPath.section)\(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

extension ViewController: TwoScrollViewDelegte{
    func twoScrollViewRefreshFooter(_ multipleScrollView: TwoScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //            self.count += 2
            //            self.footerTableView.reloadData()
            //            multipleScrollView.reloadFooterView()
            multipleScrollView.endRefreshFooter()
        }
    }
    
    func twoScrollViewRefreshHeader(_ multipleScrollView: TwoScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //            self.count = 2
            //            self.footerTableView.reloadData()
            //            multipleScrollView.reloadHeaderView()
            multipleScrollView.endRefreshHeader()
        }
    }
}

