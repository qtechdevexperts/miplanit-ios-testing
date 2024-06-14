//
//  ImageRenderingMode.swift
//  MiPlanIt
//
//  Created by Febin Paul on 28/12/20.
//  Copyright © 2020 Arun. All rights reserved.
//

import Foundation


class ImageWithoutRender: UIImage {
    override func withRenderingMode(_ renderingMode: UIImage.RenderingMode) -> UIImage {
        return self
    }
}
