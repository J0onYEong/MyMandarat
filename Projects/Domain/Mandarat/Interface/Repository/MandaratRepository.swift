//
//  MandaratRepository.swift
//  Mandarat
//
//  Created by choijunios on 12/4/24.
//

import RxSwift

public protocol MandaratRepository {
    
    // MARK: Fetching
    
    func requestMainMandarat() -> Single<[MainMandaratVO]>
    
    func requestSubMandarat(root: any Identifiable) -> Single<[SubMandaratVO]>
    
    // MARK: Saving
    
    func requestSaveMainMandarat(mainMandarat: MainMandaratVO) -> Single<Void>
}
