//
//  CoreImageFilters.swift
//  FilterShop
//
//  Created by Xue Yu on 9/17/17.
//  Copyright © 2017 XueYu. All rights reserved.
//

import CoreImage

/// This struct provide all the avliable Filters from CoreImage
struct CoreImageFilters {
    
    /**
      return all avaliable filters names as array of String
    */
    static func avaliableFilters() -> [String] {
        
        let filterCategories = [
            kCICategoryBlur,
            kCICategoryColorAdjustment,
            kCICategoryColorEffect,
            kCICategoryCompositeOperation,
            kCICategoryDistortionEffect,
            kCICategoryGradient,
            kCICategoryHalftoneEffect,
            kCICategoryReduction,
            kCICategorySharpen,
            kCICategoryStylize,
            kCICategoryTileEffect,
            kCICategoryTransition
        ]
        
        var avaliableFilters = [String]()
        
        for categoryName in filterCategories {
            avaliableFilters.append(categoryName)
            avaliableFilters.append(contentsOf: CIFilter.filterNames(inCategory: categoryName))
        }
        
        return avaliableFilters
    }
}
