//
//  EventDetailViewController.swift
//  Come On
//
//  Created by Julien Colin on 26/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import ObjectMapper
import MapKit

class EventDetailViewController: UIViewController {
    
    var eventItem: EventItem!
    
    // Outlets.
    @IBOutlet var customView: UIView!
    @IBOutlet var customViewPinEvent: UIView!
    @IBOutlet weak var customViewAvatar: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    /// Maps Pins.
    var usersAnnotations: [Int: CustomAnnotation] = [:]
    var pinEvent: CustomAnnotation!
    /// Map overlay
    var mapOverlay: MKOverlay!
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    // MARK: - View navigation
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
        checkLocationAuthorizationStatus()
        // Location settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        launchBackgroundLoopNetwork()
        
        zoomIn(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(eventItem.latitude, eventItem.longitude), 2000, 2000))
        
        addPinForEvent()
        
        startTimer()
    }

    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    var closed = false
    @IBAction func closeViewController(sender: AnyObject) {
        closed = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Timer
    
    var timer = NSTimer()
    var counter = 0
    
    func startTimer(){
        counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(EventDetailViewController.countUp), userInfo: nil, repeats: true)
    }
    
    func countUp() {
        counter += 1
    }
    
    func resetTimer(){
        timer.invalidate()
        startTimer()
    }
    
    // MARK: - Network
    
    func launchBackgroundLoopNetwork() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.fetchUsersPositions()
        }
    }
    
    func fetchUsersPositions() {
        ComeOnAPI.sharedInstance.performRequest(EventRoute.ReadMap(eventId: eventItem.id!), before: { () in
            print("Fetching users positions")
            }, success: { (json, httpCode) in
                guard let eventMap = Mapper<EventMap>().map(json) else {
                    return
                }
                for user in eventMap.users {
                    let newAnnotation = CustomAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: Double(user.latitude), longitude: Double(user.longitude)),
                        title: "title", subtitle: "subtitle", isUser: true)
                    newAnnotation.userId = user.userId
                    if let p = self.eventItem.getParticipantOfId(user.userId) {
                        newAnnotation.userAvatar = p.extendedPropertyAsObject?.avatar
                    }
                    // Move the annotation by add new + delete old
                    self.mapView.addAnnotation(newAnnotation)
                    if let previousUserPosition = self.usersAnnotations[user.userId] {
                        self.mapView.removeAnnotation(previousUserPosition)
                    }
                    self.usersAnnotations[user.userId] = newAnnotation
                }
        }) {
            if self.closed {
                return
            }
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(5 * NSEC_PER_SEC)
                ),
                dispatch_get_global_queue(priority, 0)) {
                    self.fetchUsersPositions()
            }
        }
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    // MARK: - Map
    
    /// location manager to authorize user location for Maps app
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func addPinForEvent() {
        pinEvent = CustomAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: eventItem.latitude, longitude: eventItem.longitude),
            title: "title", subtitle: "subtitle", isUser: false)
        self.mapView.addAnnotation(pinEvent)
    }
    
    func zoomIn(region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
}

extension EventDetailViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation_: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "chest"
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        guard let annotation = annotation_ as? CustomAnnotation else {
            print(annotation_)
            return v
        }
        
        if let v = v {
            v.annotation = annotation
        } else {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
            if annotation.isUser == false {
                let view = self.customViewPinEvent.copyView() as! UIView
                v!.addSubview(view)
                //                 v!.image = UIImage(named: "checkBoxValide")
            } else {
                let view = self.customView.copyView() as! UIView
                let avatarImageView = view.viewWithTag(42) as! UIImageView
                
                avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
                avatarImageView.clipsToBounds = true
                
                if let avatar = annotation.userAvatar,
                    let url = NSURL(string: "http://cdn.comeon.io/\(avatar)") {
                    getDataFromUrl(url) { (data, response, error)  in
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            guard let data = data where error == nil else { return }
                            avatarImageView.image = UIImage(data: data)
                        }
                    }
                } else {
                    avatarImageView.image = UIImage(named: "avatar2")
                }
                v!.addSubview(view)
            }
            
            
        }
        return v
        
    }
    
    
    func showRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .Walking
        
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
            
                var moved = false
                if let mapOverlay = self.mapOverlay {
                    moved = true
                    self.mapView.removeOverlay(mapOverlay)
                }
                self.mapOverlay = route.polyline
                self.mapView.addOverlay(self.mapOverlay)
                if moved == false {
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setVisibleMapRect(rect,
                        edgePadding: UIEdgeInsetsMake(40, 40, 40, 40), animated: true)
                }
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = CustomColors.purple()
        renderer.lineWidth = 5
        return renderer
    }
}


extension EventDetailViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        if counter > 3 {
            resetTimer()
            showRoute(coord, destination: pinEvent.coordinate)
        }
    }
}

class CustomAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var userId: Int!
    var userAvatar: String?
    var isUser: Bool!
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, isUser: Bool) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.isUser = isUser
    }
}
