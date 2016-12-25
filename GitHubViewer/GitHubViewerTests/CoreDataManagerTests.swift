//
//  CoreDataManagerTests.swift
//  GitHubViewer
//
//  Created by Lorna Kemp on 25/12/16.
//  Copyright © 2016 Pedro Yusim. All rights reserved.
//

import XCTest
import CoreData

class CoreDataManagerTests: XCTestCase {
    
    var pullRequestsViewController : PullRequestsViewController!
    
    var coreDataManager : CoreDataManager!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        pullRequestsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PullRequestsController") as! PullRequestsViewController
        
        coreDataManager = CoreDataManager.sharedManager() as! CoreDataManager!;
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoreDataManagerIsNotNull() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssert(coreDataManager != nil, "coreDataManager nao foi instancializada")
    }
    
    func testPullRequestsControllerIsNotNull() {
        
        XCTAssert(pullRequestsViewController != nil, "PullRequestsViewController nao foi instancializada!")
    }
    
    func testTableViewIsHidden() {
        
        let _ = pullRequestsViewController.view
        
        XCTAssert(pullRequestsViewController.tableViewPullRequests.isHidden, "tableView nao esta escondido!")
    }
    
    func testAddingRepositoryToCoreData() {
        
        let repository = Repository() as Repository!
        
        repository?.name = "Alamofire"
        repository?.repositoryDescription = "Alamofire description"
        repository?.forksCount = 12
        repository?.stargazersCount = 25
        
        let owner = Owner() as Owner!
        
        owner?.login = "alamofire"
        owner?.avatarUrl = "http://alamofire.com"
        
        repository?.owner = owner
        
        let managedObject = coreDataManager.insert(repository, withPage: 1)
        
        XCTAssert(managedObject != nil)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
