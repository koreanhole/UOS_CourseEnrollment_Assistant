//
//  SubjectTableViewController.swift
//  Search_Subject
//
//  Created by koreanhole on 2020/02/05.
//  Copyright © 2020 권순형. All rights reserved.
//

import UIKit
import Firebase

class SubjectTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    var xmlParser = XMLParser()
    var currentElement = ""
    var subjectItem: [String:String] = ["subject_no" : "", "subject_nm" : "", "class_div" : "",
                                        "subject_div" : "", "credit" : "", "dept" : "", "prof_nm" : ""]
    var subjectItems = [[String:String]]()
    var selectedItem = [String:String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "검색"
    }
    
    /*
     검색 탭 누르자마자 키보드 나오게 하려면 아래 주석 해제
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.definesPresentationContext = true
    }
 
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
 */
 
 
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text?.uppercased() {
            requestSubjectInfo(searchTerm: searchText)
            tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        subjectItems = [[String:String]]()
        tableView.reloadData()
    }

    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subjectItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell", for: indexPath) as! CourseTableViewCell
        cell.update(with: subjectItems[indexPath.row])
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let searchClosure = {(result: [String:String]) -> Void in
            self.selectedItem = result
        }
        CourseData.getCourseInfoFB(subject: self.subjectItems[indexPath.row], completion: searchClosure)
        alert.addAction(UIAlertAction(title: "강의계획표", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "showCoursePlan", sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "상세정보", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "showDetail", sender: self)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: {_ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "내 강의에 추가", style: .default, handler: {_ in
            CourseData.saveToMyCourse(data: self.subjectItems[indexPath.row])
            let addAlert = UIAlertController(title: "내 강의에 추가하였습니다.", message: self.subjectItems[indexPath.row]["subject_nm"], preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.present(addAlert, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        
        //강의 상세정보를 보기 위해서 데이터 넘겨주기
        if segue.identifier == "showDetail" {
            let SearchResultTableViewController = navController.topViewController as! SearchResultTableViewController
            SearchResultTableViewController.subjectItem = self.selectedItem

        }
        //강의 계획표 보기 위해서 데이터 넘겨주기
        else if segue.identifier == "showCoursePlan" {
            let CoursePlanTableViewController = navController.topViewController as! CoursePlanTableViewController
            CoursePlanTableViewController.subjectItem = self.selectedItem
        }
    }
}
