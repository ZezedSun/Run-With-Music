//
//  MusicListTableViewCell.swift
//  RunWithMusic
//
//  Created by SYY on 2018/12/7.
//  Copyright © 2018 Mingze Sun. All rights reserved.
//

import UIKit

class MusicListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var musicName: UILabel!
    
    @IBOutlet weak var musicNumber: UILabel!
    
    @IBOutlet weak var activeImg: UIImageView!
    
    @IBOutlet weak var musicAuthor: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setModel(model:Music){
        self.musicName.text=model.musicName
        self.musicAuthor.text=model.musicAuthor
        self.musicNumber.text=String(model.musicNum!)
        model.isActive=false;
        if AudioPlayer.activeSong() != nil {
            if AudioPlayer.activeSong() == model {
                model.isActive=true;
            }
        }
        self.activeImg.isHidden=model.isActive ?false : true
        
    }
}

