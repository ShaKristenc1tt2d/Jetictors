import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gsy_github_app_flutter/common/config/Config.dart';
import 'package:gsy_github_app_flutter/widget/GSYPullLoadWidget.dart';

/**
 * 上下拉刷新列表的通用State
 * Created by guoshuyu
 * Date: 2018-07-20
 */
// ignore: mixin_inherits_from_not_object
abstract class GSYListState<T extends StatefulWidget> extends State<T> with AutomaticKeepAliveClientMixin {
  bool isLoading = false;

  int page = 1;

  final List dataList = new List();

  final GSYPullLoadWidgetControl pullLoadWidgetControl = new GSYPullLoadWidgetControl();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @protected
  Future<Null> handleRefresh() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page = 1;
    var res = await requestRefresh();
    if (res != null && res.result) {
      pullLoadWidgetControl.dataList.clear();
      setState(() {
        pullLoadWidgetControl.dataList.addAll(res.data);
      });
    }
    resolveDataResult(res);
    isLoading = false;
    return null;
  }

  @protected
  Future<Null> onLoadMore() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page++;
    var res = await requestLoadMore();
    if (res != null && res.result) {
      setState(() {
        pullLoadWidgetControl.dataList.addAll(res.data);
      });
    }
    resolveDataResult(res);
    isLoading = false;
    return null;
  }

  @protected
  resolveDataResult(res) {
    setState(() {
      pullLoadWidgetControl.needLoadMore = (res != null && res.data != null && res.data.length == Config.PAGE_SIZE);
    });
  }

  @protected
  showRefreshLoading() {
    new Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
    });
  }

  @protected
  clearData() {
    setState(() {
      pullLoadWidgetControl.dataList.clear();
    });
  }

  ///下拉刷新数据
  @protected
  requestRefresh() async {}

  ///上拉更多请求数据
  @protected
  requestLoadMore() async {}

  ///是否需要第一次进入自动刷新
  @protected
  bool get isRefreshFirst;

  ///是否需要头部
  @protected
  bool get needHeader => false;

  ///是否需要保持
  @override
  bool get wantKeepAlive => true;

  List get getDataList => dataList;

  @override
  void initState() {
    super.initState();
    pullLoadWidgetControl.needHeader = needHeader;
    pullLoadWidgetControl.dataList = getDataList;
    if (pullLoadWidgetControl.dataList.length == 0 && isRefreshFirst) {
      showRefreshLoading();
    }
  }
}
