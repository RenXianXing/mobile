//
//  PaymentViewController.swift
//  SCOOTER
//
//  Created by RoyIM on 11/28/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit
import SwiftyJSON

class PaymentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    
    var sv:UIView?

    var arrCreditCard:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sv = UIViewController.displaySpinner(onView: self.view)
        getAllCreditCards { (json) in
            print(json)
            self.reloadCollectionView(json)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let cards = arrCreditCard {
            return cards.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cardsCollectionView.dequeueReusableCell(withReuseIdentifier: "cardcell", for: indexPath) as! CardCell
        let cardinfo = self.arrCreditCard?[indexPath.row]
        cell.setCardInfo(cardinfo)

        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        sv = UIViewController.displaySpinner(onView: self.view)
        
        if let cardinfo = self.arrCreditCard?[indexPath.row] {
            let json = cardinfo as! JSON
            let status = json["status"].stringValue
            if status == "active" {
                let alert = UIAlertController(title: "Alert", message: "Are you sure delete this card?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
                    print("default card")
                    removeCreditCard(cardid: json["card_id"].stringValue, completion: { (json) in
                        if json["success"].boolValue {
                            getAllCreditCards { (json) in
                                self.reloadCollectionView(json)
                            }
                        } else {
                            
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
                   
                }))
                
                self.present(alert, animated: true,completion: {
                    print("copmletion block")
                })
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Default Card", style: .default, handler: { (UIAlertAction) in
                    setDefaultCard(cardid: json["card_id"].stringValue, completion: { (json) in
                        if json["success"].boolValue {
                            getAllCreditCards { (json) in
                                self.reloadCollectionView(json)
                            }
                        } else {
                            
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Delete Card", style: .default, handler: { (UIAlertAction) in
                    removeCreditCard(cardid: json["card_id"].stringValue, completion: { (json) in
                        if json["success"].boolValue {
                            getAllCreditCards { (json) in
                                self.reloadCollectionView(json)
                            }
                        } else {
                            
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
                }))
                
                self.present(alert, animated: true,completion: {
                    print("copmletion block")
                })
            }
        }
     
    }
    
    func reloadCollectionView(_ json:JSON){
        self.arrCreditCard = json.array
        self.cardsCollectionView.reloadData()
        if let svVal = self.sv {
            UIViewController.removeSpinner(spinner: svVal)
        }
        
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
