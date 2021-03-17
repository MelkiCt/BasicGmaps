//
//  SavedPlaces.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import UIKit



class SavedPlacesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var coordinatesLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    
    private var place : GooglePlace? {
        didSet {
            nameLbl.text = place?.name
            addressLbl.text =  place?.formatted_address
            if let rating = place?.rating, rating > 0 {
                var str = "Rating: \(rating)"
                if let users = place?.user_ratings_total, users > 0 {
                    str += " (\(users))"
                }
                coordinatesLbl.text = str
            }
            else {
                coordinatesLbl.text = "lat: \(place?.coordinate.latitude ?? 0.0), long: \(place?.coordinate.longitude ?? 0.0)"
            }
                    
        }
    }
       
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.shadowColor = UIColor.darkGray.cgColor
        cardView.layer.shadowOpacity = 0.4
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 5
        cardView.layer.cornerRadius = 5
        
        // Initialization code
    }
    func setPlace(place: GooglePlace?) {
        self.place = place
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
