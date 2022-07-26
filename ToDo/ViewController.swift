//
//  ViewController.swift
//  ToDo
//
//  Created by Timur on 26.07.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        var str = """
{
  "id": "idish",
  "text": "textid",
  "importance": "low",
  "deadline": 1658797500,
  "done": false,
  "created_at": 1658797511,
  "changed_at": 1658797234
}
"""
        
        print(str)
        var data = str.data(using: .utf8)
        var json = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed)
        var todo = TodoItem.parse(json: json)
        print(todo)
    }


    
    
    
}

