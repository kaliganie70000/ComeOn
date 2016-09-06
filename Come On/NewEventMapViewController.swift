//
//  NewEventMapViewController.swift
//  Come On
//
//  Created by Julien Colin on 22/01/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import MapKit

class NewEventMapViewController: UIViewController {

    var region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(), 2000, 2000)
    var annotation: MKAnnotation!
    var parentVC: NewEventViewController?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBAction func closeAction(sender: AnyObject) {
        if sender as? UIBarButtonItem == okButton {
            parentVC?.currentLocation = annotation.coordinate
            parentVC?.locationTextField.text = searchBar.text
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - location manager to authorize user location for Maps app
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        mapView.showsUserLocation = true
        checkLocationAuthorizationStatus()
        // Do any additional setup after loading the view.
        reverseLocation(region.center)
        zoomTo(region)
        let tapGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(NewEventMapViewController.tapOnMap(_:)))
        tapGestureRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    func tapOnMap(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(mapView)
        let coord = mapView.convertPoint(point, toCoordinateFromView: mapView)
        reverseLocation(coord)
    }
    
    func reverseLocation(locCoord: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: locCoord, addressDictionary: nil)
        updateAnnotation(placemark)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(placemark.location!) { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            print(placeMark.addressDictionary)
            self.searchBar.text = ""
            if let locationName = placeMark.addressDictionary!["Name"] as? String {
                print(locationName)
                self.searchBar.text = locationName
            }
            if let city = placeMark.addressDictionary!["City"] as? String {
                if self.searchBar.text != "" {
                    self.searchBar.text = self.searchBar.text! + ", "
                }
                self.searchBar.text = self.searchBar.text! + city
            }
            if self.searchBar.text == "" {
                self.searchBar.text = "(\(locCoord.latitude),\(locCoord.longitude))"
                //            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                //                print(street)
                //            }
                //            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                //                print(zip)
                //            }
                //            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                //                print(country)
                //            }
            }
        }
    }
    
    func zoomTo(region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAnnotation(placemark: CLPlacemark) {
        if let annotation = self.annotation {
            self.mapView.removeAnnotation(annotation)
        }
        let newAnnotation = MKPlacemark(placemark: placemark)
        self.annotation = newAnnotation
        self.mapView.addAnnotation(newAnnotation)
    }
}

extension NewEventMapViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print(searchBar.text)
        let address = searchBar.text!
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if ((error) != nil) {
                LocalNotifications.notifSomethingBadHappend("Oups, nous n'avons pas trouvé \(address)")
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate

                self.region.center = coordinates
                self.mapView.setRegion(self.region, animated: true)
                self.okButton.enabled = true

                self.updateAnnotation(placemark)
                self.searchBar.resignFirstResponder()
            }
        })
    }
}
