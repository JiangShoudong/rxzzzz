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
//        example1()
        example2()
}


//MARK:- 订阅
    /*
     有了 Observable，我们还要使用 subscribe() 方法来订阅它，接收它发出的 Event。
     */
    private func example2() {
        /*
         第一种用法：
         （1）我们使用 subscribe() 订阅了一个 Observable 对象，该方法的 block 的回调参数就是被发出的 event 事件，我们将其直接打印出来。
         运行结果, 可以看到：
         初始化 Observable 序列时设置的默认值都按顺序通过 .next 事件发送出来。
         当 Observable 序列的初始数据都发送完毕，它还会自动发一个 .completed 事件出来。
         2）如果想要获取到这个事件里的数据，可以通过 event.element 得到。
         
         第二种用法：
         （1）RxSwift 还提供了另一个 subscribe 方法，它可以把 event 进行分类：
         通过不同的 block 回调处理不同类型的 event。
         同时会把 event 携带的数据直接解包出来作为参数，方便我们使用。
         
         （2）subscribe() 方法的 onNext、onError、onCompleted 和 onDisposed 这四个回调 block 参数都是有默认值的，即它们都是可选的。所以我们也可以只处理 onNext 而不管其他的情况。
         */
        let observable = Observable.of("A", "B", "C")
        observable.subscribe { (event) in
            print(event.element)
        }.disposed(by: disposeBag)
        observable.subscribe(onNext: { (element) in
            print(element)
        }).disposed(by: disposeBag)
        /*
         监听事件的生命周期：
         1，doOn 介绍
         （1）我们可以使用 doOn 方法来监听事件的生命周期，它会在每一次事件发送前被调用。
         （2）同时它和 subscribe 一样，可以通过不同的 block 回调处理不同类型的 event。比如：
         do(onNext:) 方法就是在 subscribe(onNext:) 前调用
         而 do(onCompleted:) 方法则会在 subscribe(onCompleted:) 前面调用。
         */
        /*
         Observable 的销毁（Dispose）:
         1，Observable 从创建到终结流程
         （1）一个 Observable 序列被创建出来后它不会马上就开始被激活从而发出 Event，而是要等到它被某个人订阅了才会激活它。
         （2）而 Observable 序列激活之后要一直等到它发出了 .error 或者 .completed 的 event 后，它才被终结。
         2，dispose() 方法
         （1）使用该方法我们可以手动取消一个订阅行为。
         （2）如果我们觉得这个订阅结束了不再需要了，就可以调用 dispose() 方法把这个订阅给销毁掉，防止内存泄漏。
         （2）当一个订阅行为被 dispose 了，那么之后 observable 如果再发出 event，这个已经 dispose 的订阅就收不到消息了。下面是一个简单的使用样例。
         3，DisposeBag
         （1）除了 dispose() 方法之外，我们更经常用到的是一个叫 DisposeBag 的对象来管理多个订阅行为的销毁：
         我们可以把一个 DisposeBag 对象看成一个垃圾袋，把用过的订阅行为都放进去。
         而这个 DisposeBag 就会在自己快要 dealloc 的时候，对它里面的所有订阅行为都调用 dispose() 方法。
 */
        observable
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
    }
    
//MARK:- 样例
    private func example1() {
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
