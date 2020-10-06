import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;





import 'dart:convert';

import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:http/http.dart' as http;
import 'package:meal_flutter/common/widgets/loading.dart';
import 'package:meal_flutter/register_page.dart';
import 'package:provider/provider.dart';

import './common/provider/userProvider.dart';
import './common/route_transition.dart';
import './kakao_register_page.dart';
import 'UIs/main_page.dart';
import 'common/color.dart';

import 'test_page.dart';




class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  void goKakaoRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(page: RegisterPage(isKakao: true,)),
    );
  }


  void goRegisterPage() {
    Navigator.push(
      context,
      FadeRoute(page: RegisterPage(isKakao: false,)),
    );
  }


  void goMainPage() {
    Navigator.push(
      context,
      FadeRoute(page: MealMainUI()),
    );
  }



  @override
  Widget build(BuildContext context) {



    UserStatus userStatus = Provider.of<UserStatus>(context);


    return LoadingModal(
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
                    Container(
                      margin: EdgeInsets.only(top: 165),
                      child: Text(
                        '오늘 뭐먹지?',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Container(
                      //margin: EdgeInsets.only(bottom: 120),
                      child: Image.asset(
                        'assets/yam_logo.jpg',
                        width: 150,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: _buildTextFields(),
                    )
                  ],
                )
              ],
            ),
          )
      ),
    );
  }

  Widget _buildTextFields() {
    return Builder(
      builder: (context){
        return Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _idController,
                  maxLines: 1,
                  maxLength: 30,
                  decoration: InputDecoration(

                    hintText: '아이디',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  maxLines: 1,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20,),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: primaryColor,
                    child: Text(
                      '로그인', style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async {
                      UserStatus userStatus = Provider.of<UserStatus>(context);
                      bool loginResult = await userStatus.loginDefault(_idController.text, _passwordController.text);
                      print(loginResult);
                      if(loginResult == true){
                        goMainPage();
                      }
                    },
                  ),
                ),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: primaryColor,
                    child: Text(
                      '회원가입', style: TextStyle(fontSize: 20, color: Colors.white),
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
                _buildDivisionLine(),
                ButtonTheme(
                  minWidth: 320,
                  height: 40,
                  child: RaisedButton(
                    color: kakaoColor,
                    child: Text(
                      '카카오톡으로 로그인', style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () async{
                      UserStatus userStatus = Provider.of<UserStatus>(context);
                      userStatus.setIsKakao(true);
//                  goKakaoRegisterPage();
                      userStatus.setIsLoading(true);
                      bool loginResult = await userStatus.loginWithKakao();
                      print(loginResult);
                      userStatus.setIsLoading(false);
                      if(loginResult == true){
//                      userStatus.loginWithKakao();
                        print('성공');
                        goMainPage();

                      }else{
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
      margin: EdgeInsets.only(top: 30, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 142,
            height: 2,
            color: Colors.black,
          ),
          Text(
            ' OR ',
            style: TextStyle(color: Colors.black),
          ),
          Container(
            width: 142,
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
              size: MediaQuery.of(context).size,
              painter: Painter2(),
            ),
            Opacity(
              opacity: 0.7,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
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
    path.cubicTo(size.width * 0.2, size.height * 0.15, size.width * 0.45,
        size.height * 0.08, size.width * 0.6, size.height * 0.12);
    path.cubicTo(size.width, size.height * 0.25, size.width, size.height * 0.25,
        size.width * 1.05, size.height * 0.02);
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
    path.cubicTo(-20, size.height * 0.2, size.width * 0.15, size.height * 0.05,
        size.width * 0.51, size.height * 0.2);
    path.cubicTo(size.width * 0.65, size.height * 0.25, size.width * 0.85,
        size.height * 0.25, size.width, size.height * 0.16);
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
