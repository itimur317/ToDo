//
//  ImageProvider.swift
//  MKInteractives
//
//  Created by Timur on 29.06.2022.
//

import Foundation
import UIKit

public class ImageProvider {
    public static func getImage(from name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: self), compatibleWith: nil) ?? UIImage()
    }
}
