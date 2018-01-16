//
//  ViewController.swift
//  rxzzz
//
//  Created by 姜守栋 on 2018/1/16.
//  Copyright © 2018年 Nick.Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let musicViewModel = MusicViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicViewModel.data.bind(to: tableView.rx.items(cellIdentifier: "musicCell")) { _, music, cell in
            cell.textLabel?.text = music.name
            cell.detailTextLabel?.text = music.singer
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Music.self).subscribe(onNext: { (music) in
            print("你选的歌曲信息【\(music)】")
        }).disposed(by: disposeBag)
    }
}

struct MusicViewModel {
    let data = Observable.just([
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树")
        ])
}

struct Music {
    let name: String
    let singer: String
    
    init(name: String, singer: String) {
        self.name = name
        self.singer = singer
    }
}

extension Music: CustomStringConvertible {
    var description: String {
        return "name: \(name) singer: \(singer)"
    }
}
