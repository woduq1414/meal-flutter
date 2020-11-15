import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:meal_flutter/UIs/servey_page.dart';
import 'package:meal_flutter/UIs/setting.dart';
import 'package:meal_flutter/common/asset_path.dart';
import 'package:meal_flutter/common/ip.dart';
import 'package:meal_flutter/common/provider/mealProvider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:meal_flutter/common/push.dart';
import 'package:meal_flutter/common/widgets/dialog.dart';
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/login_page.dart';
import 'package:provider/provider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'dart:math' as math;
import '../firebase.dart';
import 'esteregg.dart';
import 'meal_calendar.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import "package:meal_flutter/common/font.dart";

import "../common/color.dart";

import "package:meal_flutter/main.dart";

import 'meal_detail.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'package:ads/ads.dart';


GlobalKey _containerKey = GlobalKey();
FontSize fs;

//FontSize fs;
//GlobalKey _underMenuKey = GlobalKey();

class CustomStack extends Stack {
  CustomStack({children}) : super(children: children);

  @override
  CustomRenderStack createRenderObject(BuildContext context) {
    return CustomRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      overflow: overflow,
    );
  }
}

class CustomRenderStack extends RenderStack {
  CustomRenderStack({alignment, textDirection, fit, overflow})
      : super(alignment: alignment, textDirection: textDirection, fit: fit);

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    var stackHit = false;
    final children = getChildrenAsList();
    for (var child in children) {
      final StackParentData childParentData = child.parentData;
      final childHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (childHit) stackHit = true;
    }
    return stackHit;
  }
}

class MealMainUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meal',
      home: MealState(),
    );
  }
}

class MealState extends StatefulWidget {
  @override
  MealUI createState() => MealUI();
}

Offset getWidgetPos(GlobalKey key) {
  RenderBox b = key.currentContext.findRenderObject();
  return b.localToGlobal(Offset.zero);
}

Size getWidgetSize(GlobalKey key) {
  final RenderBox renderBoxRed = key.currentContext.findRenderObject();
  final size = renderBoxRed.size;
  return size;
}
BannerAd bannerAd;

class MealUI extends State<MealState> {
  int _selectedIndex = 0;
  double _selectedTop = 0;
  bool _openInfo = false;
  int _nowTab = 0;
  var _mealList = [];
  bool _getMealDataSuccess = false;
  var dayList = {};
  bool _iscalled = false;
  AdManager AdM = AdManager();
  CarouselController btnController = CarouselController();
  bool _bubbleOpened = false;
  bool _getNowMealFail = false;

  String tmp;

  var tabList = ["soup", "calendar", "setting"];

  var ratingEmojiList = ["spice", "cold", "soso", "good", "love"];



  int _count = 1;

  PushManager pm;

  List<int> _ratingStarList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    pm = PushManager();

    // pm.schedulePush(, title, body);
//    pm.NotificationAt();
//    pm.showNotification();
//    pm.dailyAtTimeNotification();

      AdManager.showBanner();
   // adMob.init();
   // bannerAd = adMob.createBannerAd();
   // bannerAd
   //   ..load().then((loaded) {
   //     if (loaded && this.mounted) {
   //       bannerAd..show();
   //     }
   //   });
    super.initState();
    getNowMealMenu();
    // getSelectedMealMenu(DateTime.now().year, DateTime.now().month);

    // getMyRatedStar();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MealStatus mealStatus = Provider.of<MealStatus>(context);
      mealStatus.getMyRatedStar();
    });
  }

  Future getMyRatedStar() async {
    http.Response res = await getWithToken(
        '${currentHost}/meals/rating/star/my?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}');
    print(res.statusCode);
    if (res.statusCode == 200) {
//      print(jsonDecode(res.body));
      var jsonBody = jsonDecode(res.body)["data"];
      for (var rating in jsonBody) {
        setState(() {
          _ratingStarList[rating["menuSeq"]] = rating["star"];
        });
      }
      return;
    } else {
      return;
    }
  }

  Future rateStar(int menuSeq, int star) async {
//    print(date);
    http.Response res = await postWithToken('${currentHost}/meals/rating/star', body: {
      "menuDate": formatDate(DateTime.now(), [yyyy, '', mm, '', dd]),
      "menus": [
        {"menuSeq": menuSeq, "star": star}
      ]
    });
    print('포스트');
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('포스트 성공');

      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    print("disposed!!!!!!!!!!!!!!!");
    try {
      bannerAd?.dispose();
    } on Exception {}

    super.dispose();
  }

  double degreeToRadian(double f) {
    return f * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
//    print(fs.s1());
    fs = FontSize(context);
    MealStatus mealStatus = Provider.of<MealStatus>(context);

    print("!!!!!!!!1");
//    print(_mealList);

//    print(getWidgetSize(_underMenuKey));

    return WillPopScope(
      onWillPop: () async {
        showCustomDialog(
            context: context,
            title: "앱을 종료할까요?",
//          content : null,
            cancelButtonText: "취소",
            confirmButtonText: "나가기",
            cancelButtonAction: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 500), () {
                if (bannerAd != null) bannerAd.dispose();
                bannerAd = null;
                print("dssssssssss");
              });

            },
            confirmButtonAction: () {
              Navigator.pop(context);
              exit(1);
            });

        return true;
      },
      child: LoadingMealModal(
        child: Scaffold(
          backgroundColor: primaryRed,
          body: SafeArea(
              child: CustomStack(
            children: <Widget>[
              Container(
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    CustomPaint(painter: CurvePainter1(), size: MediaQuery.of(context).size),
                    CustomPaint(
                      painter: CurvePainter2(),
                      size: MediaQuery.of(context).size,
                    )
                  ],
                ),
              ),
              Container(
//            key: _underMenuKey,
                child: CustomStack(
                  children: <Widget>[
                        Container(
                          child: CustomPaint(
                            painter: HalfCirclePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        ),
                        Container(
                          child: CustomPaint(
                            painter: InnerHalfCirclePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        ),
//                  Positioned(
//                    top: MediaQuery.of(context).size.height - 75 - 20,
//                    left: MediaQuery.of(context).size.width / 2 - 75,
//                    child: Image.asset(getEmoji("cold"), width: 150, height:150),
//                  ),
                        Container(
                          child: CustomPaint(
                            painter: BuchaePainter(),
                            size: MediaQuery.of(context).size,
                          ),
                        )
                      ] +
                      tabList.map<Widget>((tab) {
                        var t = 90 + (_nowTab - tabList.indexOf(tab)) * 40.0;
                        var s = _nowTab == tabList.indexOf(tab) ? 70.0 : 50.0;

                        double halfCircleVerticalRadius = MediaQuery.of(context).size.height * 0.15 / 1.4;
                        double halfCircleHorizontalRadius = MediaQuery.of(context).size.width * 0.3 / 1.4;

//                        print(math.sin(degreeToRadian(t))* (s == 70 ? 230 : 210));

//                        print(math.cos(30  * math.pi / 180));
                        return AnimatedPositioned(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              btnController.animateToPage(tabList.indexOf(tab),
                                  duration: Duration(milliseconds: 500), curve: Curves.ease);
                            },
                            child: Container(
//                        color: Colors.blue,
                              child: Image.asset(
                                getEmoji(tab),
                              ),
                            ),
                          ),
//                    margin: EdgeInsets.only(
//                      top:
//                      _nowTab == 0 ? MediaQuery.of(context).size.height*0.79 : MediaQuery.of(context).size.height * 0.85,
//                      left: _nowTab == 0
//                          ? MediaQuery.of(context).size.width * 0.5 - 33
//                          : MediaQuery.of(context).size.width * 0.5 - 80,
//                    ),
                          top: MediaQuery.of(context).size.height * 1 -
                              math.sin(degreeToRadian(t)) * halfCircleVerticalRadius -
                              s -
                              10,
                          left: (MediaQuery.of(context).size.width / 2) +
                              math.cos(degreeToRadian(t)) * halfCircleHorizontalRadius -
                              s / 2,
                          width: s,
                          height: s,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                      }).toList(),
//                  AnimatedContainer(
//                    child: GestureDetector(
//                      onTap: () {
//                        btnController.animateToPage(1);
//                      },
//                      child: Image.asset(
//                        getEmoji("calendar"),
//                        width: _nowTab == 0 ? 50 : 70,
//                      ),
//                    ),
//                    margin: EdgeInsets.only(
//                      top:
//                      _nowTab == 0 ? MediaQuery.of(context).size.height * 0.85 : MediaQuery.of(context).size.height * 0.78,
//                      left: _nowTab == 0
//                          ? MediaQuery.of(context).size.width * 0.5 + 30
//                          : MediaQuery.of(context).size.width * 0.5 - 33,
//                    ),
//                    duration: Duration(milliseconds: 400),
//                    curve: Curves.ease,
//                  ),
                ),
              ),
              CarouselSlider(
                carouselController: btnController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1,
                    onPageChanged: (index, CarouselPageChangedReason c) {
                      MealStatus mealStatus = Provider.of<MealStatus>(context);
                      setState(() {
                        _nowTab = index;
                        if (_nowTab == 1 && !_iscalled) {
                          mealStatus.setFavoriteListWithRange();
                          mealStatus.setDayList(dayList);
                          setState(() {
                            _iscalled = true;
                          });
                        }
                      });
                    }),
                items: <Widget>[
                  FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.8,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
//                    color: Colors.blue,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.035,
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        getEmoji("soup"),
                                        width: 50,
                                      ),
                                      SizedBox(width: 5),
                                      GestureDetector(
                                        onDoubleTap: () {},
                                        child: Text('오늘의 메뉴',
                                            style: TextStyle(fontSize: fs.s3, color: Colors.white, shadows: [
                                              Shadow(offset: Offset(0, 4.0), blurRadius: 10.0, color: Colors.black38),
                                            ])),
                                      ),
                                      SizedBox(width: 5),
                                      Image.asset(
                                        getEmoji("soup"),
                                        width: 50,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text('점심',
                                      style: TextStyle(fontSize: fs.s6, color: Colors.white, fontWeight: Font.normal)),
                                  Text(formatDate(DateTime.now(), [yyyy, '.', mm, '.', dd]),
                                      style: TextStyle(fontSize: fs.s7, color: Colors.white)),
                                ],
                              ),
                            ),
                            Container(
                              key: _containerKey,
                              width: MediaQuery.of(context).size.width,
//                          height: 500,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  _getMealDataSuccess
                                      ? _mealList != null
                                          ? Column(
                                              children: <Widget>[
                                                    SizedBox(
                                                      height: fs.getWidthRatioSize(0.15),
                                                    )
                                                  ] +
                                                  (_mealList).map<Widget>((menu) {
                                                    print('덩기덕 쿵덕');
                                                    return _buildMealItem(menu, _mealList.indexOf(menu));
                                                  }).toList() +
                                                  <Widget>[
                                                    SizedBox(
                                                      height: fs.getWidthRatioSize(0.15),
                                                    )
                                                  ],
                                            )
                                          : Container(
                                              margin: EdgeInsets.only(top: fs.getHeightRatioSize(0.07)),
                                              child: Text(
                                                '급식 정보가 없습니다.',
                                                style: TextStyle(color: Colors.white, fontSize: fs.s5),
                                              ))
                                      : Container(margin: EdgeInsets.all(40), child: CustomLoading()),
                                  _bubbleOpened
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _bubbleOpened = false;
                                              _openInfo = false;
                                            });
                                          },
                                          child: Container(
                                            width: fs.getWidthRatioSize(1),
                                            height: fs.getHeightRatioSize(0.6),
                                            decoration: BoxDecoration(color: Colors.transparent),
                                          ),
                                        )
                                      : Container(
                                          width: 0,
                                          height: 0,
                                        ),
                                  Positioned(
                                    child: _buildBelowItemInfo(_selectedIndex),
                                    top: _selectedTop + 5,
                                  ),
                                  Positioned(
                                    child: _buildUpperItemInfo(_selectedIndex),
                                    top: _selectedTop - 90,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
//                height : MediaQuery.of(context).size.height,
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
//                  color: Colors.blue,
//                  height: 150,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.035,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      getEmoji("calendar"),
                                      width: 50,
                                    ),
                                    SizedBox(width: 5),
                                    Text('내 급식표',
                                        style: TextStyle(fontSize: fs.s3, color: Colors.white, shadows: [
                                          Shadow(offset: Offset(0, 4.0), blurRadius: 10.0, color: Colors.black38),
                                        ])),
                                    SizedBox(width: 5),
                                    Image.asset(
                                      getEmoji("calendar"),
                                      width: 50,
                                    ),
                                  ],
                                ),
                                MealCalState(),
                                !mealStatus.isLoadingFavorite ? _buildDDayList() : CustomLoading()
                              ],
                            )),
                      ),
                    ),
                  ),
                  Container(
                      child: Container(
//                height : MediaQuery.of(context).size.height,
                    child: FractionallySizedBox(
                      heightFactor: 0.8,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
//                  color: Colors.blue,
//                  height: 150,
                          child: Setting(),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildMealItem(String mealName, int index) {
    GlobalKey _key = GlobalKey();
    return Container(
        key: _key,
        //height: 40,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: fs.s7,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _openInfo = true;
                  _selectedTop = getWidgetPos(_key).dy - getWidgetPos(_containerKey).dy + 47;
                  _selectedIndex = index;
                  _bubbleOpened = true;
                });
              },
              onTapUp: (TapUpDetails t) {
                setState(() {
                  _openInfo = false;
                });
              },
              child: Text(mealName, style: TextStyle(fontSize: fs.s5, color: Colors.white)),
            ),
            SizedBox(
              height: 7,
            ),
          ],
        ));
  }

  Widget _buildBelowItemInfo(int index) {
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
            height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
            nipLocation: NipLocation.TOP,
            color: primaryYellow,
            borderRadius: 50,
            child: FlatButton(
              child: Text(
                '자세히',
                style: TextStyle(fontSize: 15),
              ),
              color: primaryYellow,
              onPressed: () {
                print(index is int);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MealSurvey(DateTime.now(), index, _mealList[index])));
              },
            )),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildUpperItemInfo(int index) {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
          height: _openInfo ? MediaQuery.of(context).size.height * 0.06 : 0,
          nipLocation: NipLocation.BOTTOM,
          color: Colors.white,
          borderRadius: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: child,
                  axisAlignment: 1,
                  axis: Axis.horizontal,
                );
              },
              child: mealStatus.ratingStarList[index] == 0
                  ? Row(
                      key: ValueKey<List>(mealStatus.ratingStarList),
                      children: ratingEmojiList.map((x) {
                        return Material(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            onTap: () async {
                              int star = ratingEmojiList.indexOf(x) + 1;
                              setState(() {
                                mealStatus.setRatingStarList(index, star);
                              });

                              Future.delayed(Duration(milliseconds: 600), () {
                                setState(() {
                                  _bubbleOpened = false;
                                  _openInfo = false;
                                });
                              });

                              var rateResult = await rateStar(index, star);
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              child: Image.asset(
                                getEmoji(x),
                                width: 35,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(
                      key: ValueKey<List>(mealStatus.ratingStarList),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          onTap: () {
//                      int i = ratingEmojiList.indexOf(x);
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: Image.asset(
                              getEmoji(ratingEmojiList[mealStatus.ratingStarList[index] - 1]),
                              width: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ]),
        ),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildDDayList() {
    MealStatus mealStatus = Provider.of<MealStatus>(context);
    var keys = mealStatus.dayList.keys.toList();

    print(keys);

    int i = 0;

    keys.sort();
    var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Column(
        children: keys
            .where((x) {
              DateTime dParsed = DateTime.parse(x);
              var dday = dParsed.difference(now).inDays;
              print(dday);
              return dday >= 0;
            })
            .toList()
            .map((x) {
              print(x);
              return _buildDDayListItem(x, mealStatus.dayList[x], i++);
            })
            .toList());

    return ListView(
        children: keys.map((x) {
      return _buildDDayListItem(x, mealStatus.dayList[x], i++);
      ;
    }).toList());
  }

  Widget _buildDDayListItem(String date, List menus, index) {
    DateTime dParsed = DateTime.parse(date);
    var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int dday = dParsed.difference(now).inDays;
//    print(dday);
    if (dday < 0)
      return Container(
        width: 0,
        height: 0,
      ); // 개선 여지 매우 큼.
    return Builder(
      builder: (context) {
        MealStatus mealStatus = Provider.of<MealStatus>(context);
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailState(dParsed)));
            mealStatus.setFavoriteListWithRange();
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: primaryRed,
              boxShadow: index % 2 == 0
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0.1,
                        blurRadius: 0.5,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: Center(
                    child: Text(
                      'D-${dday == 0 ? 'Day' : dday}',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Color(0xffFFBB00) : primaryRed,
                  ),
                ),
                Flexible(
                  child: Container(
                      margin: EdgeInsets.only(left: fs.s7),
                      child: Text(menus.join(", "), style: TextStyle(fontSize: fs.s6, color: Colors.white), softWrap: true)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // api 가져오는 지역
  Future getNowMealMenu() async {
    Timer(const Duration(milliseconds: 7000), () {
      print('이거 되긴 되냐');
      if (!_getMealDataSuccess) {
        setState(() {
          _getNowMealFail = true;
        });
      } else {
        _getNowMealFail = false;
      }
    });

    http.Response res = await getWithToken(
      '${currentHost}/meals/menu?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}',
    );
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('안녕');
      print(jsonDecode(res.body));
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      print("ss");
      print(jsonBody);
      setState(() {
        if (jsonBody != null) {
          _getMealDataSuccess = true;
          _mealList = jsonBody;
        } else {
          _getMealDataSuccess = true;
          _mealList = null;
        }
      });

      return;
    } else {
      return;
    }
  }

  Future getSelectedMealMenu(year, month) async {
    http.Response res = await getWithToken('${currentHost}/meals/rating/favorite?year=${year}&month=${month}');
    print(res.statusCode);
    if (res.statusCode == 200) {
      print(jsonDecode(res.body));
      Map<dynamic, dynamic> jsonBody = jsonDecode(res.body)["data"];
      setState(() {
        if (jsonBody != null) {
          setState(() {
            dayList = jsonBody;
          });
        } else {}
      });
      return;
    } else {
      setState(() {
        dayList = {};
      });
    }
  }
}

// CustompPainter 지역

class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryYellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    //path.moveTo(x*0.2, y);
    //path.lineTo(x*0.8, y);
    //path.lineTo(, y);

    path.arcTo(Rect.fromLTWH(x * 0.2, y * 0.85, x * 0.6, y * 0.3), degToRad(0), degToRad(-180), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BuchaePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    //path.moveTo(x*0.2, y);
    //path.lineTo(x*0.8, y);
    //path.lineTo(, y);

    path.arcTo(Rect.fromLTWH(x * 0.34, y * 0.87, x * 0.33, y * 0.2), degToRad(-60), degToRad(-60), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class InnerHalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = primaryRed
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    //path.moveTo(x*0.2, y);
    //path.lineTo(x*0.8, y);
    //path.lineTo(, y);

    path.arcTo(Rect.fromLTWH(x * 0.37, y * 0.93, x * 0.275, y * 0.15), degToRad(0), degToRad(-180), true);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurvePainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFF4600)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, y * 0.15);
    path.cubicTo(x * 0.15, y * 0.1, x * 0.25, y * 0.1, x * 0.45, y * 0.2);
    path.cubicTo(x * 0.7, y * 0.17, x * 0.8, y * 0.17, x, y * 0.1);
    path.lineTo(x, 0);
    path.lineTo(-50, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CurvePainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFFBB00)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    final x = size.width;
    final y = size.height;
    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, y * 0.23);
    path.cubicTo(x * 0.15, y * 0.08, x * 0.4, y * 0.05, x * 0.6, y * 0.12);
    path.cubicTo(x * 0.75, y * 0.23, x * 0.92, y * 0.23, x, y * 0.1);
    path.lineTo(x, 0);
    path.lineTo(-50, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
