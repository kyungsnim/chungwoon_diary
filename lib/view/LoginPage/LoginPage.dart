import 'dart:io';
import 'dart:math';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:church_diary_app/services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;
import '../../model/CurrentUser.dart';
import '../../widget/LoginButton.dart';

import '../CreateAccountPage.dart';
import '../MainPage.dart';
import 'AppleSignInAvailable.dart';

bool isSignedIn = false;
FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // New 애플 로그인
  final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();

  // for apple login
  String errorMessage;
  var randomGenerator = Random();
  List<dynamic> info = new List(3);

  @override
  initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 1));

    // 앱 실행시 애플 사용자의 변경여부를 확인함
    if (Platform.isIOS) {
      checkLoggedInState();
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Credentials revoked");
      });
    }

    // 앱 실행시 구글 사용자의 변경여부를 확인함
    googleSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount); // 사용자가 있다면 로그인
    }, onError: (gError) {
      print("Error Message : " + gError);
    });
    googleSignIn.signInSilently();
  }

  // for apple login
  void appleLogIn() async {
    // Firebase authentication 추가 인증작업용
    final _firebaseAuth = FirebaseAuth.instance;
    List<Scope> scopes = [Scope.email, Scope.fullName];

    // 애플 로그인이 이용 가능한지 체크
    if (await AppleSignIn.isAvailable()) {
      // 로그인 동작 수행 (Face ID 또는 Password 입력)
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      // 로그인 권한여부 체크
      switch (result.status) {
        // 로그인 권한을 부여받은 경우
        case AuthorizationStatus.authorized:
          // Store user ID
          await FlutterSecureStorage()
              .write(key: "userId", value: result.credential.user);

          // 애플 로그인 인증 후 결과값으로 Firebase authentication 데이터 넣는 작업
          final appleIdCredential = result.credential;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );
          // firebase auth로 인증절차 (firebase auth를 사용안할 경우 아래 작업은 안해도 된다.)
          // credential 안에 애플 정보는 담겨 있다. (email, fullName 등)
          final authResult =
              await _firebaseAuth.signInWithCredential(credential);

          // 인증 완료되면 firebaseUser 값으로 반환
          final firebaseUser = authResult.user;

          // 애플의 fullName이 있다면 구글용 displayName으로 변환 해서 profile 업데이트 해주기
          if (scopes.contains(Scope.fullName)) {
            final displayName =
                '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
            await firebaseUser.updateProfile(displayName: displayName);
          }

          // login 정보로 컨트롤 해보자.
          saveAppleUserInfoToFirestore(firebaseUser);
          break;

        case AuthorizationStatus.error:
          print("Sign in failed: ${result.error.localizedDescription}");
          setState(() {
            errorMessage = "Sign in failed 😿";
          });
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } else {
      print('Apple SignIn is not available for your device.');
    }
  }

  // for apple login
  void checkLoggedInState() async {
    final userId = await FlutterSecureStorage().read(key: "userId");
    final appleUserUid = await FlutterSecureStorage().read(key: "appleUserUid");
    if (userId == null) {
      print("No stored user ID");
      return;
    }

    final credentialState = await AppleSignIn.getCredentialState(userId);
    switch (credentialState.status) {
      // 자동 로그인
      case CredentialStatus.authorized:
        if (appleUserUid != null && appleUserUid != "") {
          // 해당 정보 다시 가져오기
          DocumentSnapshot documentSnapshot =
              await userReference.doc(appleUserUid).get();

          // 최초 로그인에 한해 푸쉬알림 전송을 위한 토큰 별도로 저장해두기 (애플 로그인)
          // _saveDeviceToken(user.uid);

          // 현재 유저정보에 값 셋팅하기
          setState(() {
            currentUser = CurrentUser.fromDocument(documentSnapshot);
          });

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainPage(0)));
        }
        break;
      case CredentialStatus.error:
        print(
            "getCredentialState returned an error: ${credentialState.error.localizedDescription}");
        break;

      case CredentialStatus.revoked:
        print("getCredentialState returned revoked");
        break;

      case CredentialStatus.notFound:
        print("getCredentialState returned not found");
        break;

      case CredentialStatus.transferred:
        print("getCredentialState returned not transferred");
        break;
    }
  }

  // for apple login
  // controlAppleSignIn(User user) async {
  //   // 사용자 정보 DB에 저장해주기
  //   if (mounted && user != null) {
  //     await saveAppleUserInfoToFirestore(user);
  //
  //     // 사용자 정보 저장 후 로그인 이후 화면으로 진입
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => MainPage(0)));
  //   }
  // }

  submitUsernameAndGrade() {
    // final form = _formKey.currentState;
    // if (form.validate()) {
    //   form.save();
    var randomGenerator = Random();
    var nameList = [
      '순진한',
      '배고픈',
      '행복한',
      '졸린',
      '어리석은',
      '멍한',
      '기뻐하는',
      '우울한',
      '재미있는',
      '재치있는',
      '흥겨운',
      '외로운',
      '피곤한',
      '산뜻한',
      '귀여운',
      '예쁜',
      '유쾌한',
      '발랄한',
      '다부진',
      '신나는'
    ];
    var nameTwoList = [
      '돌고래',
      '여우',
      '강아지',
      '고양이',
      '사자',
      '나무늘보',
      '코끼리',
      '미국인',
      '영국인',
      '가나인',
      '한국인',
      '중국인',
      '태국인',
      '베트콩',
      '몽골인',
      '참새',
      '딱따구리',
      '앵무새',
      '낙타',
      '쥐',
      '조랑말',
      '타조'
    ];
    var nameRandomNumber = randomGenerator.nextInt(nameList.length - 1);
    var nameTwoRandomNumber = randomGenerator.nextInt(nameTwoList.length - 1);
    var userRandomNumber = randomGenerator.nextInt(9999);
    // 입력한 username, phoneNumber 추가
    setState(() {
      info[0] =
          "${nameList[nameRandomNumber]}${nameTwoList[nameTwoRandomNumber]}$userRandomNumber";
      info[1] = 0;
      info[2] = "";
    });

    // if(userName)
    // SnackBar snackBar = SnackBar(content: Text('Welcome ' + userName));
    // _scaffoldKey.currentState.showSnackBar(snackBar);

    // 회원가입시 push notification 사용을 위한 사용자 푸쉬 토큰 저장해주기
    // _saveDeviceToken();
    // }
  }

  // for apple login
  saveAppleUserInfoToFirestore(User user) async {
    // 해당 유저의 db정보 가져오기
    DocumentSnapshot documentSnapshot = await userReference.doc(user.uid).get();
    var randomNumber = 1 + randomGenerator.nextInt(48); // 1~49 랜덤 숫자 생성

    // 해당 유저의 db정보가 없다면
    if (!documentSnapshot.exists) {
      // 유저정보를 셋팅하는 페이지로 이동 (애플은 사용자 정보 중 username이나 phone number를 저장하고 있지 않아서 별도 페이지에서 받아오도록 구현함)
      // final info = await Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => CreateAccountPage()));

      // 애플 로그인인 경우 정보입력화면 없이 진행
      submitUsernameAndGrade();

      // 유저정보 셋팅된 값으로 db에 set
      userReference.doc(user.uid).set({
        'id': user.uid,
        'profileName': user.displayName != null ? user.displayName : "",
        'userName': info[0], // username
        'grade': info[1], // phoneNumber
        'inbodyScore': info[2],
        'url': "",
        'randomNumber': randomNumber, // 프로필사진 랜덤 동물 사진으로 설정
        'email': user.email,
        'role': "general",
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'loginType': "Apple",
        "validateByAdmin": false, // 최초 회원가입시 관리자 검증 false
      });
    } else {
      userReference.doc(user.uid).update({'loginType': "Apple"});
    }
    // Store user ID
    await FlutterSecureStorage().write(key: "appleUserUid", value: user.uid);
    // 해당 정보 다시 가져오기
    documentSnapshot = await userReference.doc(user.uid).get();

    // 최초 로그인에 한해 푸쉬알림 전송을 위한 토큰 별도로 저장해두기 (애플 로그인)
    // _saveDeviceToken(user.uid);

    // 현재 유저정보에 값 셋팅하기
    setState(() {
      currentUser = CurrentUser.fromDocument(documentSnapshot);
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainPage(1)));
  }

  // 로그인 상태 여부에 따라 isSignedIn flag값을 변경해줌
  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (mounted) {
      if (signInAccount != null) {
        await saveUserInfoToFirestore();

        // setState(() {
        //   isSignedIn = true;
        // });
      } else {
        setState(() {
          isSignedIn = false;
        });
      }
    }
  }

  saveUserInfoToFirestore() async {
    // 현재 구글 로그인된 사용자 정보 가져오기
    final GoogleSignInAccount gCurrentUser = googleSignIn.currentUser;
    // 해당 유저의 db정보 가져오기
    DocumentSnapshot documentSnapshot =
        await userReference.doc(gCurrentUser.id).get();

    // 해당 유저의 db정보가 없다면
    if (!documentSnapshot.exists) {
      // 유저정보를 셋팅하는 페이지로 이동
      // final info = await Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => CreateAccountPage()));

      // 정보입력화면 없이 진행
      submitUsernameAndGrade();

      // 유저정보 셋팅된 값으로 db에 set
      userReference.doc(gCurrentUser.id).set({
        'id': gCurrentUser.id,
        'profileName': gCurrentUser.displayName,
        'userName': info[0], // username
        'grade': info[1], // phoneNumber
        'inbodyScore': info[2],
        'url': gCurrentUser.photoUrl,
        'email': gCurrentUser.email,
        "role": "general",
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'loginType': "Google",
        "validateByAdmin": false, // 최초 회원가입시 관리자 검증 false
      });
    } else {
      userReference.doc(gCurrentUser.id).update({'loginType': "Google"});
    }
    // 해당 정보 다시 가져오기
    documentSnapshot = await userReference.doc(gCurrentUser.id).get();

    // 푸쉬알림 전송을 위한 토큰 별도로 저장해두기 (구글 로그인)
    // _saveDeviceToken(gCurrentUser.id);

    // 현재 유저정보에 값 셋팅하기
    setState(() {
      currentUser = CurrentUser.fromDocument(documentSnapshot);
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainPage(1)));
  }

  googleLoginUser() async {
    final GoogleSignInAccount account = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await account.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    controlSignIn(account);
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    // authResult로 무언가 해야 하나..?
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
        ),
        Center(
          child: ClipRRect(
            // 이미지 테두리반경 등 설정시 필요
            child: Image.asset("assets/images/login_background.jpg",
                // width: MediaQuery.of(context).size.width * 1,
                // height: MediaQuery.of(context).size.height * 1,
                fit: BoxFit.cover),
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.2),
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
        ),
        Center(
          child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                // Text(
                //   'Church Diary',
                //   style: TextStyle(fontFamily: 'Nanum',
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 40),
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                InkWell(
                    onTap: () => googleLoginUser(),
                    child: loginButton(
                        context,
                        'assets/images/google_icon.png',
                        'Sign in with Google',
                        Colors.black54,
                        Colors.white.withOpacity(0.8),
                        Colors.black12)),
                SizedBox(height: 10),
                // KakaoLogin(),
                // SizedBox(height: 10),
                // iOS 기기에서만 보이도록
                appleSignInAvailable.isAvailable
                    ? InkWell(
                        onTap: () => appleLogIn(),
                        // onTap: () => _signInWithApple(context),
                        child: loginButton(
                            context,
                            'assets/images/apple_icon.png',
                            'Sign in with Apple',
                            Colors.white,
                            Colors.black,
                            Colors.black12))
                    : Container(),
                Spacer(),
                // Text('© Copyright ${DateTime.now().year} by Church diary',
                //     style: TextStyle(fontFamily: 'Nanum', color: Colors.white54, fontSize: 12)),
                // SizedBox(height: 10),
                // Text('로그인이 잘 안되시나요? (고객센터 연결)', style: GoogleFonts.montserrat())
              ])),
        )
      ],
    ));
  }
}
