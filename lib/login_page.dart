import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as Math;
import 'package:ads/ads.dart';
import 'dart:io' show Platform;
import 'package:firebase_admob/firebase_admob.dart';

import 'dart:convert';

import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/find_email_page.dart';
import 'package:meal_flutter/register_page.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import './common/route_transition.dart';
import './kakao_register_page.dart';
import 'UIs/main_page.dart';
import 'common/color.dart';

import 'common/font.dart';

import 'common/widgets/dialog.dart';
import 'find_password_page.dart';
import 'firebase.dart';
import 'test_page.dart';

FontSize fs;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  // AdMobManager adMob = AdMobManager();


  @override
  void initState() {
    // var _bannerAd = adMob.createBannerAd();
    // _bannerAd?.dispose();
    // var _bannerAd = adMob.createBannerAd();
    // _bannerAd.dispose();
    // adMob = AdMobManager();
    // adMob.dispose();


    AdManager.hideBanner();


  }

  void goKakaoRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(
          page: RegisterPage(
        isKakao: true,
      )),
    );
  }

  void goRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(
          page: RegisterPage(
        isKakao: false,
      )),
    );
  }

  void goMainPage() {
    Navigator.push(
      context,
      FadeRoute(page: MealState()),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserStatus userStatus = Provider.of<UserStatus>(context);



   // var _bannerAd = adMob.createBannerAd();
   // try{
   //   _bannerAd.dispose();
   // }on Exception{
   //
   // }

    fs = FontSize(context);

    return LoadingModal(
      child: WillPopScope(
        onWillPop: () async {


          showCustomDialog(
              context: context,
              title: "앱을 종료할까요?",
//          content : null,
              cancelButtonText: "취소",
              confirmButtonText: "나가기",
              cancelButtonAction: () {
                Navigator.pop(context);
              },
              confirmButtonAction: () {
                Navigator.pop(context);
                exit(1);
              });

          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  _buildUpperCurvePainter(),
                  //SizedBox(height: 100,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30, bottom: 3),
                        decoration: BoxDecoration(border: Border(
                          bottom: BorderSide(
                            color: primaryRed, width: 3
                          )
                        )),
                        child: Text(
                          "모두의 급식",
                          style: TextStyle(fontSize: fs.s6, fontWeight: Font.normal, letterSpacing: 8, color: primaryRed),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: (){Ads.showBannerAd(state: this);},
                        child: Container(
                          child: Text(
                            "YAMMEAL",
                            style: TextStyle(
                              fontSize: fs.s2,
                              fontWeight: Font.bold,
                              letterSpacing: 8,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        //margin: EdgeInsets.only(bottom: 120),
                        child: Image.asset(
                          'assets/yam_logo.png',
                          width: 150,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        child: _buildTextFields(),
                      )
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildTextFields() {
    final node = FocusScope.of(context);
    return Builder(
      builder: (context) {
        return Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                TextField(

                  controller: _idController,
                  maxLines: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(40),
                  ],
                  style: TextStyle(
                    height: 1
                  ),
                  onEditingComplete: () => node.nextFocus(),
                  decoration: InputDecoration(
                    hintText: '이메일',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 12, 0, 12),

                    isDense: true,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: _passwordController,
                  maxLines: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(40),
                  ],
                  onSubmitted: (_) => node.unfocus(),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 12, 0, 12),

                    isDense: true,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                ButtonTheme(
                  minWidth: 320,
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: RaisedButton(
                    color: primaryRedDark,
                    child: Text(
                      '로그인',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      UserStatus userStatus = Provider.of<UserStatus>(context);
                      bool loginResult = await userStatus.loginDefault(_idController.text, _passwordController.text);
                      print(loginResult);
                      if (loginResult == true) {
                        goMainPage();
                      }else{
                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text("이메일 또는 비밀번호가 올바르지 않습니다!"), duration: Duration(seconds: 2),));
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.000,
                ),
                ButtonTheme(
                  minWidth: 320,
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: RaisedButton(
                    color: primaryRedDark,
                    child: Text(
                      '회원가입',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      UserStatus userStatus = Provider.of<UserStatus>(context);
                      userStatus.setIsKakao(false);
//                  goKakaoRegisterPage();

                      goRegisterPage();
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.005,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        UserStatus userStatus = Provider.of<UserStatus>(context);
                        userStatus.setIsKakao(false);
                        Navigator.push(
                            context,
                            FadeRoute(
                                page: FindEmailPage())
                        );
                      },
                      child: Text(
                        "이메일 찾기",
                        style: TextStyle(
                          fontSize: fs.s7,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        UserStatus userStatus = Provider.of<UserStatus>(context);
                        userStatus.setIsKakao(false);
                        Navigator.push(
                          context,
                          FadeRoute(
                              page: FindPasswordPage())
                        );
                      },
                        child: Text(
                      "비밀번호 찾기",
                      style: TextStyle(
                        fontSize: fs.s7,
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ))
                  ],
                ),
                _buildDivisionLine(),
                ButtonTheme(
                  minWidth: 320,
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: RaisedButton(
                    color: kakaoColor,
                    child: Text(
                      '카카오톡으로 로그인',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      UserStatus userStatus = Provider.of<UserStatus>(context);
                      userStatus.setIsKakao(true);
//                  goKakaoRegisterPage();
//                      userStatus.setIsLoading(true);
                      bool loginResult = await userStatus.loginWithKakao();
                      print(loginResult);
//                      userStatus.setIsLoading(false);

                      if (loginResult == true) {
//                      userStatus.loginWithKakao();
                        print('성공');
                        goMainPage();
                      } else {
                        goKakaoRegisterPage();
                      }
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }

  Widget _buildDivisionLine() {
    return Container(
      margin:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02, bottom: MediaQuery.of(context).size.height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 2,
            color: Colors.black,
          ),
          Text(
            ' 간편 로그인 ',
            style: TextStyle(color: Colors.black),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 2,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildUpperCurvePainter() {
    return Builder(
      builder: (context) {
        return Stack(
          children: <Widget>[
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.7),
              painter: Painter2(),
            ),
            Opacity(
              opacity: 0.7,
              child: CustomPaint(
                size:Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.7),
                painter: Painter1(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Painter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color(0xffFF7039)
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, size.height * 0.27);
    path.cubicTo(
        size.width * 0.2, size.height * 0.15, size.width * 0.45, size.height * 0.08, size.width * 0.6, size.height * 0.12);
    path.cubicTo(size.width, size.height * 0.25, size.width, size.height * 0.25, size.width * 1.05, size.height * 0.02);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (Math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Painter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0;

    Path path = new Path();
    path.moveTo(-50, 0);
    path.lineTo(-50, size.height * 0.2);
    path.cubicTo(-20, size.height * 0.2, size.width * 0.15, size.height * 0.05, size.width * 0.51, size.height * 0.2);
    path.cubicTo(
        size.width * 0.65, size.height * 0.25, size.width * 0.85, size.height * 0.25, size.width, size.height * 0.16);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  num degToRad(num deg) => deg * (Math.pi / 180.0);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
