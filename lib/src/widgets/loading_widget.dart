import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///按返回键时触发
typedef BackPressCallback = Future<void> Function(BackPressType);

class LoadingScaffold extends StatefulWidget {
  final bool isShowLoadingAtNow;
  final BackPressType backPressType;
  final BackPressCallback? backPressCallback;
  final Operation operation;
  final Widget child;

  const LoadingScaffold(
      {Key? key,
      this.isShowLoadingAtNow = false,
      this.backPressType = BackPressType.CLOSE_CURRENT,
      this.backPressCallback,
      required this.operation,
      required this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoadingState();
  }
}

class LoadingState extends State<LoadingScaffold> {
  late VoidCallback listener;

  Future<bool> _onWillPop() => Future.value(false); //禁掉返回按钮和右滑关闭

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.operation._notifier = ValueNotifier<bool>(false);
    if (widget.isShowLoadingAtNow != true) {
      widget.operation._notifier.value = false;
    } else {
      widget.operation._notifier.value = true;
    }
    listener = () {
      setState(() {
        _hideKeyBord();
      });
    };
    widget.operation._notifier.addListener(listener);
  }

  void _hideKeyBord() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.operation._notifier.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Offstage(
          offstage: false,
          child: widget.child,
        ),
        Offstage(
          offstage: widget.operation._notifier.value != true,
          child: widget.operation._notifier.value != true
              ? _loadingWidget()
              : _WillPopScopeWidget(), //显示loading，则禁掉返回按钮和右滑关闭
        )
      ],
    );
  }

  Widget _WillPopScopeWidget() {
    return WillPopScope(
        onWillPop: () async {
          if (null != widget.backPressCallback) {
            widget.backPressCallback!(widget.backPressType);
          }
          if (widget.backPressType == BackPressType.SBLOCK) {
            _onWillPop(); //阻止返回
            return false;
          } else if (widget.backPressType == BackPressType.CLOSE_CURRENT) {
            widget.operation.setShowLoading(false); //关闭当前页
          } else if (widget.backPressType == BackPressType.CLOSE_PARENT) {
            Navigator.pop(context); //关闭当前页及当前页的父页
          }
          return true;
        },
        child: _loadingWidget());
  }

  Widget _loadingWidget() {
    return Container(
        alignment: Alignment.center,
        color: Colors.black12,
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              alignment: Alignment.center,
              color: Colors.black45,
              width: 90.0,
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(
                    width: 28.0,
                    height: 28.0,
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                    ),
                  ),
                  // SizedBox(width: 15.0),
                  // Text(
                  //   '玩命加载中...',
                  //   style: TextStyle(
                  //     fontSize: 17.0,
                  //     color: Colors.white,
                  //     letterSpacing: 0.8,
                  //     fontWeight: FontWeight.normal,
                  //     decoration: TextDecoration.none,
                  //   ),
                  // )
                ],
              ),
            )));
  }
}

enum BackPressType {
  SBLOCK, //阻止返回
  CLOSE_CURRENT, //关闭当前页
  CLOSE_PARENT //关闭当前页及当前页的父页
}

class Operation {
  late ValueNotifier<bool> _notifier;

  void setShowLoading(bool isShow) {
    _notifier.value = isShow;
  }

  bool get isShow => _notifier.value;
}
