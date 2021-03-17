//
//  SavedPlacesViewController.swift
//  map
//
//  Created by Melki on 17/03/21.
//

import UIKit

protocol SavedListProtocol: AnyObject {
    func showPlace(place: GooglePlace)
}


class SavedPlacesViewController: UIViewController {
    let cellReusableID = "Cell"
    var savedPlacesVM: SavedPlaceVM!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyMessageView: UIView!
    weak var delegate: SavedListProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        savedPlacesVM = SavedPlaceVM()
        savedPlacesVM.isNoData.bind { [weak self] in
            if ($0 == true) {
                self?.emptyMessageView.isHidden = false
                self?.tableView.isHidden = true
                self?.tableView.tableHeaderView = nil
            }
            else {
                self?.emptyMessageView.isHidden = true
                self?.tableView.isHidden = false
                self?.showTableViewHeader()
                self?.tableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    

    
    func showTableViewHeader() {
        let headerView: UIView = UIView.init(frame: CGRect.init(x: 1, y: 70, width: 276, height: 36))
        headerView.backgroundColor = UIColor.white

        let labelView: UILabel = UILabel.init(frame: CGRect.init(x: 16, y: 12, width: 276, height: 24))
        labelView.text = "Your Saved List"
        labelView.font = UIFont.systemFont(ofSize: 18, weight: .medium)

        headerView.addSubview(labelView)
        self.tableView.tableHeaderView = headerView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SavedPlacesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPlacesVM.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableID, for: indexPath) as! SavedPlacesTableViewCell
        cell.setPlace(place: savedPlacesVM.placeFor(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let place = savedPlacesVM.placeFor(index: indexPath.row) else {
            return
        }
        delegate?.showPlace(place: place)
        self.navigationController?.popViewController(animated: true)
    }
}
