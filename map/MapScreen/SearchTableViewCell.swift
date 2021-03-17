//
//  SearchTableViewCell.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    private var place : GooglePlace? {
        didSet {
            nameLbl.text = place?.name
        }
    }
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPlace(place: GooglePlace?) {
        self.place = place
    }
    

}
