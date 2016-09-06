//
//  TimelineViewController.swift
//  Come On
//
//  Created by Julien Colin on 04/10/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper



class TimelineViewController: UIViewController, GridComponent, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewCalendar: UITableView!
    @IBOutlet weak var tableViewEvents: UITableView!
    
    var rootVC: HomeViewController!

    var refreshControl: UIRefreshControl!
    var listEvent: [EventItem]?
    var listCalendar: [DateItem] = []
    var timer: NSTimer!
    var lastPageToLoad = -1

    let idUser: Int = (ComeOnAPI.sharedInstance.auth?.id)!
    
    @IBOutlet weak var noEventLabel: UILabel!
    var selectedEvent: EventItem?
    //var nbPages: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("idUser: \(idUser)")
        self.updateList(0)
        tableViewCalendar.rowHeight = 75
        self.tableViewCalendar.delegate = self
        self.tableViewCalendar.dataSource = self
        
        tableViewEvents.rowHeight = 150
        self.tableViewEvents.delegate = self
        self.tableViewEvents.dataSource = self
        //refreshControl = UIRefreshControl()
        //tableViewEvents.addSubview(refreshControl)
        self.tableViewEvents.tableFooterView = UIView(frame: CGRectZero)
        self.tableViewCalendar.tableFooterView = UIView(frame: CGRectZero)
    }
    
    

    func didScrollToViewController(scrollView: UIScrollView) {
        print("@TODO: Antoine")
        listEvent?.removeAll()
        updateList(0)
    }


    func findAccordingDate(indexEvent: Int) -> Int {
        let event = listEvent![indexEvent]
        print("find according date: \(indexEvent):")
        print(event.toString())
        var ret = 0
        repeat {
            if computeDate(event.date_start!, item: listCalendar[ret]) == true {
                return ret
            }
            ret += 1
        } while ret < listCalendar.count
        print("result finding: \(ret)")

        return ret
    }

    func findSoonestDate() -> Int {
        let today = DateItem(src: NSDate())
        //print("item: \(item.day)-\(item.month)-\(item.year)")
        var ret = 0
        repeat {
            if computeDate(today, item: listCalendar[ret]) == true {
                return ret
            }
            ret += 1
        } while ret < listCalendar.count
        print("soonest: \(ret)")
        return ret
    }

    func findAccordingEvent(pos: Int) -> Int {
        let today = listCalendar[pos]
        var ret = 0
        repeat {
            if (computeDate(today, item: listEvent![ret].date_start!) == true) {
                return ret
            }
            ret += 1
        } while ret < listEvent!.count
        //for (var i = 0; i < listEvent!.count && computeDate(today, item: listEvent![i].date_start!) == false; ) {  }
        return ret
    }

    func computeDate(today: DateItem, item: DateItem) -> Bool {
        let cDay = item.day - today.day
        let cMonth = item.month - today.month
        let cYear = item.year - today.year
        print("compute date: \(cDay) : \(cMonth) : \(cYear)")
        if cDay >= 0 && cMonth >= 0 && cYear >= 0 {
            return true
        }
        return false
    }
    
    func appendTab(result: [EventItem]) {
        if self.listEvent?.count == nil {
            self.listEvent = result
        }
        for item in result {
            self.listEvent?.append(item)
        }
    }

    func updateList2(page: Int) {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.ReadEvents(page: page),
            success: { (json, httpCode) -> Void in
                if let event = Mapper<Event>().map(json) {
                    print("nb event list: \(self.listEvent?.count)")
                    print("nb event:\(event.results?.count)")
                    print(event.results)

                    
                    
                    
                    
                   
                        self.appendTab(event.results!)
            
                    
                    
            
                    
                    if event.currentPage != event.nbPages {
                        /*if event.currentPage! != event.nbPages! - 1 {
                            self.lastPageToLoad = page + 1
                        }*/
                        self.updateList2(page + 1)
                        // redo requete
                    } else if event.results?.count > 0 || self.listEvent?.count > 0 {
                        self.tableViewEvents.delegate = self
                        self.tableViewEvents.dataSource = self
                        self.tableViewEvents.reloadData()
                        self.listEvent!.sortInPlace({ $0.date_start?.date!.compare(($1.date_start?.date)!) == NSComparisonResult.OrderedAscending })
                        
                        //if self.listEvent?.count > 1 {
                            self.setListCalendar()
                        //}
                        
                        self.tableViewCalendar.delegate = self
                        self.tableViewCalendar.dataSource = self
                        
                        self.tableViewCalendar.reloadData()
                        
                        if self.listEvent?.count > 1 {
                            let soonest = self.arrangeCalendar()
                            self.arrangeEvents(soonest)
                        }
                        self.noEventLabel.hidden = true
                        self.tableViewEvents.scrollEnabled = true
                        self.tableViewCalendar.scrollEnabled = true
                    } else {
                        self.noEventLabel.hidden = false
                        self.tableViewEvents.scrollEnabled = false
                        self.tableViewCalendar.scrollEnabled = false
                        
                    }

                }
            },
            failure: { (json, httpCode) -> Void in
                print("error get list event!")
        })
    }
    
    func updateList(page: Int) {
        
        ComeOnAPI.sharedInstance.performRequest(EventRoute.ReadEvents(page: page),
            success: { (json, httpCode) -> Void in
                if let event = Mapper<Event>().map(json) {
                
                    self.appendTab(event.results!)
                    
                    if event.currentPage != event.nbPages {
                        self.updateList(page + 1)
                    } else if event.results?.count > 0 || self.listEvent?.count > 0 {
                        self.listEvent!.sortInPlace({ $0.date_start?.date!.compare(($1.date_start?.date)!) == NSComparisonResult.OrderedAscending })
                        
                        self.setListCalendar()
                        
                        self.tableViewEvents.reloadData()
                        self.tableViewCalendar.reloadData()

                        if self.listEvent?.count > 1 {
                            let soonest = self.arrangeCalendar()
                            self.arrangeEvents(soonest)
                        }
                        self.noEventLabel.hidden = true
                        
                    } else {
                        self.noEventLabel.hidden = false
                        self.tableViewEvents.scrollEnabled = false
                        self.tableViewCalendar.scrollEnabled = false
                    }
                    
                    
                }
       
            },
            failure: { (json, httpCode) -> Void in
                print("error get list event!")
            })
                
    }

    func arrangeCalendar() -> Int {
        var soonest = findSoonestDate()
        if soonest == listCalendar.count {
            print("soonest == listCalendar")
            soonest = soonest - 1
        }
        let indexS: NSIndexPath = NSIndexPath(forRow: soonest, inSection: 0)
        print("------------------>\n\(indexS)")
        tableViewCalendar.scrollToRowAtIndexPath(indexS, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        tableViewCalendar.selectRowAtIndexPath(indexS, animated: true, scrollPosition: .Top)
        return soonest
    }

    func arrangeEvents(soonest: Int) {
        let according = findAccordingEvent(soonest)
        print("arrangeEvent: \(according)")
        let indexA: NSIndexPath = NSIndexPath(forRow: according, inSection: 0)
        
        tableViewEvents.scrollToRowAtIndexPath(indexA, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        tableViewEvents.selectRowAtIndexPath(indexA, animated: true, scrollPosition: .Top)
    }

    func setListCalendar() {
        listCalendar.removeAll()
        var i = 0
        var j = 0

        while i < listEvent!.count {
            if j == 0 || listCalendar[j - 1].month != listEvent![i].date_start?.month || listCalendar[j - 1].day != listEvent![i].date_start?.day {
                listCalendar.append(listEvent![i].date_start!)
                j += 1
            }
            print("for i = \(i) -> month:\(listCalendar[j - 1].month)-\(listEvent![i].date_start?.month) Day:\(listCalendar[j - 1].day)-\(listEvent![i].date_start?.day)")

            i += 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index: NSIndexPath = (sender as? NSIndexPath)!

        if segue.identifier == "manageEventSegue" && index.row < self.listEvent?.count {
            print("hello bro !!!")
            print("index: \(index)")
            let event: EventItem = listEvent![index.row]
            let cell = tableViewEvents.cellForRowAtIndexPath(index) as? EventTableViewCell
            let vc = segue.destinationViewController as? ManageEventViewController
            vc?.eventItem = event
            vc?.cell = cell
            vc?.dateSet = writtingDate(event.date_start!)
            vc?.descriptionSet = event.description
            print("vc item: \(vc?.eventItem)")

        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewCalendar {
            return listCalendar.count
            //return 5
        } else {
            if listEvent?.count == nil {
                return 0
            }
            return listEvent!.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == tableViewCalendar {
            let cell = tableView.dequeueReusableCellWithIdentifier("calendarCustomCellIdentifier") as! CalendarTableViewCell
            //let cell = tableView.dequeueReusableCellWithIdentifier("calendarCustomCellIdentifier", forIndexPath: indexPath) as! CalendarTableViewCell
            cell.labelDayDate.text = "\(listCalendar[indexPath.row].day)"
            cell.labelMonthDate.text = "\(listCalendar[indexPath.row].abrMonth[listCalendar[indexPath.row].month - 1])"
            cell.item = listCalendar[indexPath.row]
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCustomCellIdentifier", forIndexPath: indexPath) as! EventTableViewCell
            
            if indexPath.row < listEvent?.count {
                
                //cell.labelTime.text = "\(listEvent![indexPath.row].string_date_start!)"
                print("cell for indexpath: \(indexPath.row)")
                cell.labelTime.text = self.writtingDate(listEvent![indexPath.row].date_start!)
                cell.labelTitle.text = "\(listEvent![indexPath.row].title!)"
                cell.labelMessage.text = "\(listEvent![indexPath.row].messages!)"
                cell.labelParticipant.text = "\(listEvent![indexPath.row].participants!.count)"
                cell.event = listEvent![indexPath.row]
                if listEvent![indexPath.row].ownerId == idUser {
                    cell.btnValidEvent.hidden = true
                } else {
                    cell.setCheckBox(listEvent![indexPath.row].state!)
                }
                
                //cell.initAccordingEvent(listEvent![indexPath.row])
                //print("print listEvent[] : \(unsafeAddressOf(listEvent![indexPath.row]))")
                //print("print according \(unsafeAddressOf(cell.event)) and \(unsafeAddressOf(listEvent![indexPath.row]))")
                
            }
            
            return cell
            //let cell = tableView.dequeueReusableCellWithIdentifier("eventCustomCellIdentifier") as! EventTableViewCell
            
        }
    }
    
    func writtingDate(date: DateItem) -> String {
        let today = DateItem(src: NSDate())
        var str: String = ""
        
        if (today.year == date.year &&
            today.month == date.month &&
            today.day == date.day) {
            str += "Aujourd'hui à "
        } else if (today.year == date.year &&
                today.month == date.month &&
                today.day == date.day - 1) {
            str += "Demain à "
        } else {
            str += "\(date.day) \(date.fullMonth[date.month - 1]) à "
        }
        
        if date.hour == 0 {
            str += "minuit"
        } else {
            str += "\(date.hour)h"
        }
        return str
    }

    func doSomething() {
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(TimelineViewController.endOfWork), userInfo: nil, repeats: true)
    }

    func endOfWork() {
        refreshControl.endRefreshing()
        tableViewEvents.reloadData()
        timer.invalidate()
        timer = nil
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        /*if refreshControl.refreshing {
            doSomething()
            self.updateList()
        }*/
        let visibleRow = tableViewEvents.indexPathsForVisibleRows
        tableViewEvents.scrollToRowAtIndexPath(visibleRow![0], atScrollPosition: UITableViewScrollPosition.Top, animated: true)

        //printRow(visibleRow!)
        let date = findAccordingDate(visibleRow![0].row)

        let indexS: NSIndexPath = NSIndexPath(forRow: date, inSection: 0)
        tableViewCalendar.scrollToRowAtIndexPath(indexS, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        tableViewCalendar.selectRowAtIndexPath(indexS, animated: true, scrollPosition: .Top)

    }

    func printRow(table: [NSIndexPath]) {
        for index in table {
            print(index.row)
        }
        listEvent![table[0].row].toString()
        print("----------------")
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tableViewCalendar {
            print("toto")
            let cell = tableViewCalendar.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor(red: 229, green: 229, blue: 229, alpha: 1.0)
            //let cell = tableView.dequeueReusableCellWithIdentifier("calendarCustomCellIdentifier", forIndexPath: indexPath) as! CalendarTableViewCell
            print("indexpath: \(indexPath.row)")
            if self.listCalendar.count > 1 {
                self.arrangeEvents(indexPath.row)
            }
        } else {
            if indexPath.row < self.listEvent?.count {
                self.performSegueWithIdentifier("manageEventSegue", sender: indexPath)
            }
        }
    }

}
