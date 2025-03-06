import 'dart:ui';
/*
* getScreenTopHeight 相当于状态栏的高度
* getScreenBottomHeight 安全区域底部距离屏幕底部的距离(底部有圆角, 例如iPhoneX系列)
* Packages/flutter/src/material/constans.dart 这里面有一些系统设置的高度 包括工具栏 tabbbar的高度..
* */
class ScreenSizeInfo {
  ///获取屏幕宽度
  static double getScreenWidth () {

    //每个逻辑像素的设备像素数
    double pixelRatio =  window.devicePixelRatio;
    //当前设备屏幕宽度
    double width = window.physicalSize.width / pixelRatio;

    return width;
  }

  ///获取屏幕高度
  static double getScreenHeight () {

    //每个逻辑像素的设备像素数
    double pixelRatio =  window.devicePixelRatio;
    //当前设备屏幕宽度
    double width = window.physicalSize.height / pixelRatio;

    return width;
  }

  ///顶部宽度
  static double getScreenTopHeight () {

    //每个逻辑像素的设备像素数
    double pixelRatio =  window.devicePixelRatio;
    //当前设备屏幕顶部高度
    double height = window.padding.top / pixelRatio;

    return height;
  }

  ///底部宽度
  static double getScreenBottomHeight () {

    //每个逻辑像素的设备像素数
    double pixelRatio =  window.devicePixelRatio;
    //当前设备屏幕底部高度
    double height = window.padding.bottom / pixelRatio;

    return height;
  }
}