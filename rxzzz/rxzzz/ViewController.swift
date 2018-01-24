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

    @IBOutlet weak var lable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let musicViewModel = MusicViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        example1()
        example5()
}
    //MARK:- Subjects
    /*
        有时我们希望 Observable 在运行时能动态地“获得”或者说“产生”出一个新的数据，再通过 Event 发送出去。比如：订阅一个输入框的输入内容，当用户每输入一个字后，这个输入框关联的 Observable 就会发出一个带有输入内容的 Event，通知给所有订阅者。
        这个就可以使用下面将要介绍的 Subjects 来实现。
     
        一、Subjects基本介绍
        （1）Subjects 既是订阅者，也是 Observable：
            说它是订阅者，是因为它能够动态地接收新的值。
            说它又是一个 Observable，是因为当 Subjects 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。
     
        （2）一共有四种 Subjects，分别为：PublishSubject、BehaviorSubject、ReplaySubject、Variable。他们之间既有各自的特点，也有相同之处：
            首先他们都是 Observable，他们的订阅者都能收到他们发出的新的 Event。
            直到 Subject 发出 .complete 或者 .error 的 Event 后，该 Subject 便终结了，同时它也就不会再发出 .next 事件。
            对于那些在 Subject 终结后再订阅他的订阅者，也能收到 subject 发出的一条 .complete 或 .error 的 event，告诉这个新的订阅者它已经终结了。
            他们之间最大的区别只是在于：当一个新的订阅者刚订阅它的时候，能不能收到 Subject 以前发出过的旧 Event，如果能的话又能收到多少个。
     
        （3）Subject 常用的几个方法：
            onNext(:)：是 on(.next(:)) 的简便写法。该方法相当于 subject 接收到一个 .next 事 件。
            onError(:)：是 on(.error(:)) 的简便写法。该方法相当于 subject 接收到一个 .error 事件。
            onCompleted()：是 on(.completed) 的简便写法。该方法相当于 subject 接收到一个 .completed 事件。
        二、PublishSubject
            是最普通的Subject，不需要初始值就能创建；
            订阅者不能接收订阅之前的Event
         二、BebaviorSubject
            需要通过一个默认值来创建；
            当一个订阅者订阅它的时候， 这个订阅者会立即收到BebaviorSubject 上一个 发出的event， 之后就跟正常情况一样， 它也会接收到BebaviorSubject之后发出的新的event
         三、ReplaySubject
            ReplaySubject 在创建时候需要设置一个 bufferSize，表示它对于它发送过的 event 的缓存个数。
            比如一个 ReplaySubject 的 bufferSize 设置为 2，它发出了 3 个 .next 的 event，那么它会将后两个（最近的两个）event 给缓存起来。此时如果有一个 subscriber 订阅了这个 ReplaySubject，那么这个 subscriber 就会立即收到前面缓存的两个 .next 的 event。
            如果一个 subscriber 订阅已经结束的 ReplaySubject，除了会收到缓存的 .next 的 event 外，还会收到那个终结的 .error 或者 .complete 的 event。
         四、Variable
     
     */
    private func example5() {
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        subject.onNext("111")
        subject.subscribe(onNext: { (string) in
            print("第一次订阅: ", string)
        }, onCompleted: {
            print("第1次订阅：onCompleted")
        })
            .disposed(by: disposeBag)
        
        subject.onNext("222")
        subject.subscribe(onNext: { (string) in
            print("第2次订阅: ", string)
        }, onCompleted: {
            print("第2次订阅：onCompleted")
        })
            .disposed(by: disposeBag)
        
        subject.onNext("333")
        subject.onCompleted()
        subject.onNext("444")
        
        subject.subscribe(onNext: { string in
            print("第3次订阅：", string)
        }, onCompleted:{
            print("第3次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
    }
//MARK:- 观察者（Observer）
    /*
     一、介绍：
     观察者的作用就是监听事件，然后对这个事件作出响应。或者说任何响应事件的行为都是观察者。比如：
     1.当我们点击按钮，弹出一个提示框，这个提示框就是观察者 Observer<Void>
     2.当我们请求一个远程的json数据，将其打印出来，那个这个“打印json数据”就是观察者 Observer<JSON>
     二、直接在subscibe、bind方法中创建观察者
     1.在subscribe方法中创建
     （1）创建观察者最直接的方法就是在Observable的subscribe方法后面描述当事件放生时，需要如何做出响应。比如onNext，onError， onComplete
     2.在bind方法中创建
     （1）我们创建一个定时生成索引数的Observable序列，并将索引数不断显示在lable标签上
     三、使用AnyOberver创建观察者
     AnyOberver可以用来描述任意一种观察者
     1.配合subscribe方法使用：
     2.配合bindTo方法使用
     四、使用Binder创建观察者
     也可配合Observable的数据绑定方法（bindTo）使用
     
     五、自定义可绑定属性
     我们想让UI控件创建出来就有一些观察者，而不必每次都为他们单独去创建观察者。比如，我们想让lable创建出来就有个fontSize可绑定属性，它会根据事件值自动改变标签的文字大小
     */
    
    // 五、自定义可绑定属性
    private func example4() {
        
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
        observable
            .map {
                CGFloat($0)
            }
            .bind(to: lable.rx.fontSize)
            .disposed(by: disposeBag)
    }
    private func example3() {
        
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//        observable
//            .map {
//                "当前索引数：\($0)"
//            }
//            .bind { [weak self] text in
//                self?.lable.text = text
//            }
//            .disposed(by: disposeBag)
        let observer: Binder = Binder(lable) { (view, text) in
            view.text = text
        }
        observable
            .map {
            "当前索引数：\($0)"
        }
            .bind(to: observer)
        
            .disposed(by: disposeBag)
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

extension Reactive where Base: UILabel {
    var fontSize: Binder<CGFloat> {
        return Binder(self.base) { lable, fontSize in
            lable.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
// 自定义可绑定属性
extension UILabel {
    var fontSize: Binder<CGFloat> {
        return Binder(self) { (lable, fontSize) in
            lable.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

extension Music: CustomStringConvertible {
    var description: String {
        return "name: \(name) singer: \(singer)"
    }
}
