import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:meal_flutter/common/provider/userProvider.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'dart:math' as math;
import 'meal_calendar.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;

GlobalKey _containerKey = GlobalKey();

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

class MealUI extends State<MealState> {
  int _selectedIndex = 0;
  double _selectedTop = 0;
  bool _openInfo = false;
  int _nowTab = 0;
  var _mealList = [];

  @override
  void initState() {
    super.initState();
    getNowMealMenu();
  }

  @override
  Widget build(BuildContext context) {
    print("!!!!!!!!1");
    print(_mealList);
    _mealList.map((menu) {
      print(menu);
    });
    return Scaffold(
      backgroundColor: Color(0xffFF5454),
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Container(
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
            child: Stack(
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
                Container(
                  child: CustomPaint(
                    painter: BuchaePainter(),
                    size: MediaQuery.of(context).size,
                  ),
                ),
                AnimatedPositioned(
                  child: Image.asset(
                    'assets/soup.png',
                    width: _nowTab == 0 ? 70 : 50,
                  ),
                  bottom:
                      _nowTab == 0 ? MediaQuery.of(context).size.height * 0.1 : MediaQuery.of(context).size.height * 0.05,
                  left: _nowTab == 0
                      ? MediaQuery.of(context).size.width * 0.5 - 35
                      : MediaQuery.of(context).size.width * 0.5 - 80,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                ),
                AnimatedPositioned(
                  child: Image.asset(
                    'assets/calendar.png',
                    width: _nowTab == 0 ? 50 : 70,
                  ),
                  bottom:
                      _nowTab == 0 ? MediaQuery.of(context).size.height * 0.05 : MediaQuery.of(context).size.height * 0.1,
                  left: _nowTab == 0
                      ? MediaQuery.of(context).size.width * 0.5 + 30
                      : MediaQuery.of(context).size.width * 0.5 - 35,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                )
              ],
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
                enableInfiniteScroll: false,
                autoPlay: false,
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                onPageChanged: (index, CarouselPageChangedReason c) {
                  setState(() {
                    _nowTab = index;
                  });
                }),
            items: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: 40,
                      ), //left: 40, right: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/soup.png',
                                width: 50,
                              ),
                              Text('오늘의 메뉴', style: TextStyle(fontSize: 32, color: Colors.white)),
                              Image.asset(
                                'assets/soup.png',
                                width: 50,
                              ),
                            ],
                          ),
                          Text('점심', style: TextStyle(fontSize: 25, color: Colors.white)),
                          Text(formatDate(DateTime.now(), [yyyy, '.', mm, '.', dd]),
                              style: TextStyle(fontSize: 20, color: Colors.white)),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/spice.png',
                                  width: 35,
                                ),
                                Image.asset(
                                  'assets/cold.png',
                                  width: 35,
                                ),
                                Image.asset(
                                  'assets/soso.png',
                                  width: 35,
                                ),
                                Image.asset(
                                  'assets/good.png',
                                  width: 35,
                                ),
                                Image.asset(
                                  'assets/love.png',
                                  width: 35,
                                ),
                              ],
                            ),
                            decoration:
                                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [
                              new BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(1, 4),
                                blurRadius: 3,
                                spreadRadius: 1,
                              )
                            ]),
                          )
                        ],
                      ),
                    ),
                    Container(
                      key: _containerKey,
                      width: MediaQuery.of(context).size.width,
                      height: 500,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            child: Column(
                              children: _mealList.map<Widget>((menu) {
                                print(_mealList.indexOf(menu));
                                return _buildMealItem(menu, _mealList.indexOf(menu));
                              }).toList(),
                            ),
                            top: 40,
                          ),


                          // Positioned(
                          //   child: _buildMealItem('치킨 가라아게덮밥', 0),
                          //   top: 60,
                          // ),
                          // Positioned(
                          //   child: _buildMealItem('건새우시래기된장국', 1),
                          //   top: 120,
                          // ),
                          // Positioned(
                          //   child: _buildMealItem('쫄면야채무침', 2),
                          //   top: 180,
                          // ),
                          // Positioned(
                          //   child: _buildMealItem('콘치즈버터구이', 3),
                          //   top: 240,
                          // ),
                          // Positioned(
                          //   child: _buildMealItem('배추김치', 4),
                          //   top: 300,
                          // ),
                          // Positioned(
                          //   child: _buildMealItem('요구르트', 5),
                          //   top: 360,
                          // ),
                          Positioned(
                            child: _buildBelowItemInfo(_selectedIndex),
                            top: _selectedTop,
                          ),
                          Positioned(
                            child: _buildUpperItemInfo(_selectedIndex),
                            top: _selectedTop - 100,
                          ),
//                          Positioned(
////                            top : 0,
////                            child: Container(
////                              width: 100,
////                              height: 100,
////                              color: Colors.blue,
////                            ),
////                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/calendar.png',
                            width: 50,
                          ),
                          Text('내 급식표', style: TextStyle(fontSize: 32, color: Colors.white)),
                          Image.asset(
                            'assets/calendar.png',
                            width: 50,
                          ),
                        ],
                      ),
                      MealCalState(),
                    ],
                  ))
            ],
          ),
        ],
      )),
    );
    return Builder(
      builder: (context) {
        return SafeArea(
            child: Stack(
          children: <Widget>[
            Container(
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
              child: Stack(
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
                  Container(
                    child: CustomPaint(
                      painter: BuchaePainter(),
                      size: MediaQuery.of(context).size,
                    ),
                  ),
                  AnimatedPositioned(
                    child: Image.asset(
                      'assets/soup.png',
                      width: _nowTab == 0 ? 70 : 50,
                    ),
                    bottom:
                        _nowTab == 0 ? MediaQuery.of(context).size.height * 0.1 : MediaQuery.of(context).size.height * 0.05,
                    left: _nowTab == 0
                        ? MediaQuery.of(context).size.width * 0.5 - 35
                        : MediaQuery.of(context).size.width * 0.5 - 80,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.ease,
                  ),
                  AnimatedPositioned(
                    child: Image.asset(
                      'assets/calendar.png',
                      width: _nowTab == 0 ? 50 : 70,
                    ),
                    bottom:
                        _nowTab == 0 ? MediaQuery.of(context).size.height * 0.05 : MediaQuery.of(context).size.height * 0.1,
                    left: _nowTab == 0
                        ? MediaQuery.of(context).size.width * 0.5 + 30
                        : MediaQuery.of(context).size.width * 0.5 - 35,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.ease,
                  )
                ],
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1,
                  onPageChanged: (index, CarouselPageChangedReason c) {
                    setState(() {
                      _nowTab = index;
                    });
                  }),
              items: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 40,
                        ), //left: 40, right: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/soup.png',
                                  width: 50,
                                ),
                                Text('오늘의 메뉴', style: TextStyle(fontSize: 32, color: Colors.white)),
                                Image.asset(
                                  'assets/soup.png',
                                  width: 50,
                                ),
                              ],
                            ),
                            Text('점심', style: TextStyle(fontSize: 25, color: Colors.white)),
                            Text(formatDate(DateTime.now(), [yyyy, '.', mm, '.', dd]),
                                style: TextStyle(fontSize: 20, color: Colors.white)),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              width: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/spice.png',
                                    width: 35,
                                  ),
                                  Image.asset(
                                    'assets/cold.png',
                                    width: 35,
                                  ),
                                  Image.asset(
                                    'assets/soso.png',
                                    width: 35,
                                  ),
                                  Image.asset(
                                    'assets/good.png',
                                    width: 35,
                                  ),
                                  Image.asset(
                                    'assets/love.png',
                                    width: 35,
                                  ),
                                ],
                              ),
                              decoration:
                                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [
                                new BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(1, 4),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                )
                              ]),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              children: _mealList.map<Widget>((menu) {
                                return _buildMealItem('치킨 가라아게덮밥', 0);
                              }),
                            ),

                            // Positioned(
                            //   child: _buildMealItem('치킨 가라아게덮밥', 0),
                            //   top: 60,
                            // ),
                            // Positioned(
                            //   child: _buildMealItem('건새우시래기된장국', 1),
                            //   top: 120,
                            // ),
                            // Positioned(
                            //   child: _buildMealItem('쫄면야채무침', 2),
                            //   top: 180,
                            // ),
                            // Positioned(
                            //   child: _buildMealItem('콘치즈버터구이', 3),
                            //   top: 240,
                            // ),
                            // Positioned(
                            //   child: _buildMealItem('배추김치', 4),
                            //   top: 300,
                            // ),
                            // Positioned(
                            //   child: _buildMealItem('요구르트', 5),
                            //   top: 360,
                            // ),
                            Positioned(
                              child: _buildBelowItemInfo(_selectedIndex),
                              top: _selectedTop,
                            ),
                            Positioned(
                              child: _buildUpperItemInfo(_selectedIndex),
                              top: _selectedTop - 100,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/calendar.png',
                              width: 50,
                            ),
                            Text('내 급식표', style: TextStyle(fontSize: 32, color: Colors.white)),
                            Image.asset(
                              'assets/calendar.png',
                              width: 50,
                            ),
                          ],
                        ),
                        MealCalState(),
                      ],
                    ))
              ],
            ),
          ],
        ));
      },
    );
//    return Scaffold(
//      backgroundColor: Color(0xffFF5454),
//      body: _buildBody(),
//    );
  }

  Widget _buildMealItem(String mealName, int index) {
    GlobalKey _key = GlobalKey();
    return Container(
      key: _key,
      //height: 40,
      child: Column(
        children: <Widget>[
          SizedBox(height: 7,),
          GestureDetector(
            // onLongPressUp: () {
            //   print("!@@@@@@@@@@@@@@@@@@@@@@@@@@@이거 됨?");
            //   setState(() {
            //     _openInfo = false;
            //     //_selectedIndex = 0;
            //     //_selectedTop = 0;
            //   });
            // },
            onLongPress: () {
              setState(() {
                _openInfo = true;
                _selectedTop = getWidgetPos(_key).dy - getWidgetPos(_containerKey).dy + 47;
                _selectedIndex = index;
              });
              // print(_key.currentContext.size);
              // RenderBox b = _key.currentContext.findRenderObject();
              // print(getWidgetPos(_containerKey));
              print('keypress');
            },
            onLongPressUp: () {
              print('lpUp');
            },
            onTapUp: (TapUpDetails t) {
              print('tapup');
              setState(() {
                _openInfo = false;
              });
            },
            child: Text(mealName, style: TextStyle(fontSize: 25, color: Colors.white)),
          ),
          SizedBox(height: 7,),
        ],
      )
    );
  }

  Widget _buildBelowItemInfo(int index) {
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? 50 : 0,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
          height: _openInfo ? 50 : 0,
          nipLocation: NipLocation.TOP,
          color: Colors.white,
          borderRadius: 50,
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/spice.png',
                width: 35,
              ),
              Image.asset(
                'assets/cold.png',
                width: 35,
              ),
              Image.asset(
                'assets/soso.png',
                width: 35,
              ),
              Image.asset(
                'assets/good.png',
                width: 35,
              ),
              Image.asset(
                'assets/love.png',
                width: 35,
              ),
            ],
          ),
        ),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildUpperItemInfo(int index) {
    return AnimatedOpacity(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _openInfo ? 50 : 0,
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(50), boxShadow: [
          new BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(1, 3),
            blurRadius: 2,
            spreadRadius: 0.5,
          )
        ]),
        child: SpeechBubble(
          height: _openInfo ? 50 : 0,
          nipLocation: NipLocation.BOTTOM,
          color: Colors.grey,
          borderRadius: 50,
          child: Row(
            children: <Widget>[
              Image.asset(
                'assets/cup.png',
                width: 35,
              ),
              Image.asset(
                'assets/umji.png',
                width: 35,
              ),
              Image.asset(
                'assets/salty.png',
                width: 35,
              ),
            ],
          ),
        ),
      ),
      opacity: _openInfo ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
    );
  }

  // api 가져오는 지역
  Future getNowMealMenu() async {
    http.Response res = await http.get('http://meal-backend.herokuapp.com/api/meals/menu?menuDate=${formatDate(DateTime.now(), [yyyy, '', mm, '', dd])}', headers: {
      "Authorization": await getToken(),
    });
    print(res.statusCode);
    if (res.statusCode == 200) {
      print('안녕');
      print(jsonDecode(res.body));
      List<dynamic> jsonBody = jsonDecode(res.body)["data"];
      print("ss");
      print(jsonBody);

      setState(() {
        _mealList = jsonBody;
      });

      return;
    } else {
      return;
    }
  }
}

// CustompPainter 지역

class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFFBB00)
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
      ..color = Color(0xffFF5454)
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
      ..color = Color(0xffFF5454)
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
