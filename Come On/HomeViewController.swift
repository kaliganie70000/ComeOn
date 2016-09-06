//
//  HomeViewController.swift
//  Come On
//
//  Created by Julien Colin on 28/09/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit

// Implement this protocol on viewcontroller who want to receive events for didAppear
protocol GridComponent {
    var rootVC: HomeViewController! { get set }
    func didScrollToViewController(scrollView: UIScrollView)
}

class HomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewControllers: [[UIViewController]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        let contactsStoryboard = UIStoryboard(name: "Contacts", bundle: nil)
        let timelineStoryboard = UIStoryboard(name: "Timeline", bundle: nil)
        let newEventStoryboard = UIStoryboard(name: "NewEvent", bundle: nil)
        let controlPanelStoryboard = UIStoryboard(name: "ControlPanel", bundle: nil)
        let contactsVc = contactsStoryboard.instantiateViewControllerWithIdentifier("ContactsViewControllerId")
        let timelineVc = timelineStoryboard.instantiateViewControllerWithIdentifier("TimelineViewControllerId")
        let newEventVc = newEventStoryboard.instantiateViewControllerWithIdentifier("NewEventViewControllerId")
        let controlPanelVc = controlPanelStoryboard.instantiateViewControllerWithIdentifier("ControlPanelViewControllerId")

        viewControllers = [[controlPanelVc],
                           [newEventVc, timelineVc, contactsVc]]
        
        initConstraintsOfViewControllersInsideScrollView()
    }

    private func initConstraintsOfViewControllersInsideScrollView() {
        let horizontalWidthOfContentViewConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Width, multiplier: CGFloat(viewControllers[1].count), constant: 0)
        view.addConstraint(horizontalWidthOfContentViewConstraint)
        
        for i in 0 ..< viewControllers[1].count {
            let newViewController = viewControllers[1][i]
            let newView = newViewController.view
            
            if var vc = newViewController as? GridComponent {
                vc.rootVC = self
            }
            contentView.addSubview(newView)
            addChildViewController(newViewController)
            
            newView.translatesAutoresizingMaskIntoConstraints = false
            
            // Top - Bottom - Width constraints are all same for each page of the scrollview
//            let verticalTopConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
//            view.addConstraint(verticalTopConstraint)

            let verticalBottomConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            view.addConstraint(verticalBottomConstraint)
            
            let verticalTopConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Height, multiplier: 2, constant: 0)
            view.addConstraint(verticalTopConstraint)
            
            let horizontalConstraintWidth = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Width, multiplier: CGFloat(viewControllers[1].count), constant: 0)
            view.addConstraint(horizontalConstraintWidth)
            
            // Left - Right constraints depends of the position of the controller to place
            var horizontalLeftConstraint: NSLayoutConstraint!
            if i == 0 {
                horizontalLeftConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            } else {
                let lastView = viewControllers[1][i - 1].view
                horizontalLeftConstraint = NSLayoutConstraint(item: lastView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            }
            view.addConstraint(horizontalLeftConstraint)
            if i == viewControllers[1].count - 1 {
                let horizontalRightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: newView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
                view.addConstraint(horizontalRightConstraint)
            }
        }
        
        
        // Temporary
        let controlPanelVc = viewControllers[0][0]
        let controlPanelVcView = controlPanelVc.view

        if var vc = controlPanelVc as? GridComponent {
            vc.rootVC = self
        }
        contentView.addSubview(controlPanelVcView)
        addChildViewController(controlPanelVc)
        
        controlPanelVcView.translatesAutoresizingMaskIntoConstraints = false
        let verticalTopConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: controlPanelVcView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        view.addConstraint(verticalTopConstraint)
        
        let verticalHeightConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: controlPanelVcView, attribute: NSLayoutAttribute.Height, multiplier: 2, constant: 0)
        view.addConstraint(verticalHeightConstraint)
        
        let horizontalConstraintWidth = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: controlPanelVcView, attribute: NSLayoutAttribute.Width, multiplier: CGFloat(viewControllers[1].count), constant: 0)
        view.addConstraint(horizontalConstraintWidth)
        
        // Left - Right constraints depends of the position of the controller to place
        let horizontalLeftConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: controlPanelVcView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        view.addConstraint(horizontalLeftConstraint)
    }
    
    
    // Scrollview features for sub-ViewControllers
    
    /// Return to LoviewViewController
    func logOut() {
        dismissViewControllerAnimated(true) {}
        ComeOnAPI.sharedInstance.disconnectAndReset()
    }
    
    /// Use the mainscroll to go to a specific page
    ///
    /// - parameter page: Number of the page to scroll on.
    ///
    ///   page 0 -> CreateEvent
    ///
    ///   page 1 -> TimeLine
    ///
    ///   page 2 -> Contacts
    func scrollToPage(page: Int, animated: Bool = true) {
        guard let vc = viewControllers[1][page] as UIViewController? else { return }
        scrollView.setContentOffset(vc.view.frame.origin, animated: false)
    }

        // Private
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingOrDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollViewDidEndScrollingOrDecelerating(scrollView)
    }
    
    private func scrollViewDidEndScrollingOrDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        guard let vc = viewControllers[1][page] as? GridComponent else {
            return
        }
        vc.didScrollToViewController(scrollView)
    }
}
