import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:church_diary_app/view/MainPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class WriteDiaryPage extends StatefulWidget {
  final diary;

  WriteDiaryPage({this.diary});

  @override
  _WriteDiaryPageState createState() => _WriteDiaryPageState();
}

class _WriteDiaryPageState extends State<WriteDiaryPage> {
  TextStyle style = TextStyle(fontFamily: 'Nanum', fontSize: 20.0);
  TextEditingController _firstAnswerController;
  TextEditingController _secondAnswerController;
  TextEditingController _thirdAnswerController;
  TextEditingController _fourthAnswerController;
  TextEditingController _fifthAnswerController;

  var _firstAnswer;
  var _secondAnswer;
  var _thirdAnswer;
  var _fourthAnswer;
  var _fifthAnswer;
  var _imageUrl;
  bool _imageChanged;

  var _firstQuestion;
  var _secondQuestion;
  var _thirdQuestion;
  var _fourthQuestion;
  var _fifthQuestion;

  DateTime _summitDate;

  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing;

  File _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _summitDate = DateTime.now();

    print('_summitDate.weekday : ${_summitDate.weekday}');

    switch (_summitDate.weekday) {
      case 0:
        sundayQuestionSetting();
        break;
      case 6:
        saturdayQuestionSetting();
        break;
      default:
        questionSetting();
        break;
    }

    setState(() {
      _firstAnswerController = TextEditingController(
          text: widget.diary != null ? widget.diary.firstAnswer : "");
      _secondAnswerController = TextEditingController(
          text: widget.diary != null ? widget.diary.secondAnswer : "");
      _thirdAnswerController = TextEditingController(
          text: widget.diary != null ? widget.diary.thirdAnswer : "");
      _fourthAnswerController = TextEditingController(
          text: widget.diary != null ? widget.diary.fourthAnswer : "");
      _fifthAnswerController = TextEditingController(
          text: widget.diary != null ? widget.diary.fifthAnswer : "");
      _imageUrl = widget.diary != null && widget.diary.imageUrl != ""
          ? widget.diary.imageUrl
          : "";
      _firstAnswer = _firstAnswerController.text;
      _secondAnswer = _secondAnswerController.text;
      _thirdAnswer = _thirdAnswerController.text;
      _fourthAnswer = _fourthAnswerController.text;
      _fifthAnswer = _fifthAnswerController.text;

      _imageChanged = false;

      _summitDate =
          widget.diary != null ? widget.diary.summitDate : DateTime.now();
      processing = false;
    });
  }

  sundayQuestionSetting() {
    // ?????? ????????? ???????????? ???????????? ??????????????? ????????? ????????? ??????
    FirebaseFirestore.instance
        .collection('defaultSundayQuestion')
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        var question = value.docs[0].data();

        setState(() {
          _firstQuestion = widget.diary != null
              ? widget.diary.firstQuestion
              : question['firstQuestion'];
        });
      }
    });
  }

  saturdayQuestionSetting() {
    // ?????? ????????? ???????????? ???????????? ??????????????? ????????? ????????? ??????
    FirebaseFirestore.instance
        .collection('defaultSaturdayQuestion')
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        var question = value.docs[0].data();

        setState(() {
          _firstQuestion = widget.diary != null
              ? widget.diary.firstQuestion
              : question['firstQuestion'];
        });
      }
    });
  }

  questionSetting() {
    // ?????? ????????? ???????????? ???????????? ??????????????? ????????? ????????? ??????
    FirebaseFirestore.instance
        .collection('question')
        .where('questionDate',
            isGreaterThanOrEqualTo: DateTime(
                _summitDate.year, _summitDate.month, _summitDate.day, 0, 0, 0))
        .where('questionDate',
            isLessThan: DateTime(_summitDate.year, _summitDate.month,
                _summitDate.day + 1, 0, 0, 0))
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        var question = value.docs[0].data();

        setState(() {
          _firstQuestion = widget.diary != null
              ? widget.diary.firstQuestion
              : question['firstQuestion'];
          _secondQuestion = widget.diary != null
              ? widget.diary.secondQuestion
              : question['secondQuestion'];
          _thirdQuestion = widget.diary != null
              ? widget.diary.thirdQuestion
              : question['thirdQuestion'];
          _fourthQuestion = widget.diary != null
              ? widget.diary.fourthQuestion
              : question['fourthQuestion'];
          _fifthQuestion = widget.diary != null
              ? widget.diary.fifthQuestion
              : question['fifthQuestion'];
        });
      } else {
        // ?????? ????????? ?????? ????????? ????????? ?????? ??????????????? ????????????
        FirebaseFirestore.instance
            .collection('defaultQuestion')
            .get()
            .then((value) {
          if (value.docs != null) {
            var question = value.docs[0].data();

            setState(() {
              _firstQuestion = question['firstQuestion'];
              _secondQuestion = question['secondQuestion'];
              _thirdQuestion = question['thirdQuestion'];
              _fourthQuestion = question['fourthQuestion'];
              _fifthQuestion = question['fifthQuestion'];
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text("Write diary",
            style: TextStyle(
                fontFamily: 'Nanum',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.only(left: 10),
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
            size: 25,
          ),
          iconSize: 30,
        ),
      ),
      key: _key,
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              child: Text('?????????',
                                  style: TextStyle(
                                      fontFamily: 'Nanum',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 3),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: Colors.black54, width: 0.5))),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                        "${_summitDate.year}-${_summitDate.month}-${_summitDate.day}"),
                                    SizedBox(width: 10),
                                    Icon(Icons.calendar_today,
                                        color: Colors.black)
                                  ],
                                ),
                                onTap: () async {
                                  DateTime picked = (await showDatePicker(
                                    context: context,
                                    initialDate: _summitDate,
                                    firstDate: DateTime(_summitDate.year - 5),
                                    lastDate: DateTime(_summitDate.year + 5),
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme:
                                              ColorScheme.light().copyWith(
                                            primary: Colors.black,
                                          ),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child,
                                      );
                                    },
                                  ));
                                  if (picked.isAfter(DateTime.now())) {
                                    alertNotCheckFuturePopup();
                                  } else if (picked != null) {
                                    setState(() {
                                      _summitDate = picked;
                                    });

                                    // ?????? ????????? ??????????????? ?????????????????? ???????????? ???????????? ?????? ????????? ?????? ???????????? ??????
                                    print(
                                        '_summitDate.weekday : ${_summitDate.weekday}');

                                    switch (_summitDate.weekday) {
                                      case 0:
                                        sundayQuestionSetting();
                                        break;
                                      case 6:
                                        saturdayQuestionSetting();
                                        break;
                                      case 7:
                                        sundayQuestionSetting();
                                        break;
                                      default:
                                        questionSetting();
                                        break;
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),

              // ????????? ?????? ??????
              // 1. ???????????? ?????? ??????
              // 1-0. ????????? icon ????????????
              // 1-1. ????????? ?????? ??????????????? ??????
              // 1-2. Image.file ??? ????????? ???????????? ????????????
              // 1-3. _imageUrl ????????? ??? url ??????
              // 2. ???????????? ?????? ??????
              // 2-0. imageUrl?????? ????????? ???????????? (CachedNetworkImage)
              // 2-1. ????????? ?????? ??????????????? ??????
              // 2-2. Image.file ??? ????????? ???????????? ????????????
              // 2-3. ???????????? ????????? ?????? ????????? ??? ??????????
              // 2-4. ??????????????? ????????? ??????
              //     ?????? url ????????? ????????? ??????
              //      firestore ??? url ?????? ????????????
              // 2-5.
              InkWell(
                onTap: () {
                  getGalleryImage();
                },
                child: _imageUrl != null &&
                        _imageUrl != "" &&
                        _imageFile == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text('?????? ??????',
                                        style: TextStyle(
                                            fontFamily: 'Nanum',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ],
                            ),
                            SizedBox(height: 3),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 5,
                                        color: Colors.white24)
                                  ]),
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Stack(children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 5,
                                            color: Colors.white24)
                                      ]),
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: CachedNetworkImage(
                                    imageUrl: _imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      )
                    : _imageFile == null //
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        child: Text('?????? ??????',
                                            style: TextStyle(
                                                fontFamily: 'Nanum',
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: Stack(children: [
                                    Center(
                                        child: Icon(
                                      Icons.photo_library,
                                      size: 40,
                                    )),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.symmetric(
                                              horizontal: BorderSide(
                                                  color: Colors.black54,
                                                  width: 0.5))),
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1,
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        child: Text('?????? ??????',
                                            style: TextStyle(
                                                fontFamily: 'Nanum',
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide(
                                              color: Colors.black54,
                                              width: 0.5))),
                                  width: MediaQuery.of(context).size.width * 1,
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: Image.file(
                                    _imageFile,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ), // ????????? ?????? ??? ??? ?????? ????????? ???????????? ?????? ???????????? ?????? ???????????? ????????????
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                              child: Text('?????? 1. $_firstQuestion',
                                  style: TextStyle(
                                      fontFamily: 'Nanum',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                    SizedBox(height: 3),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.symmetric(
                                  horizontal: BorderSide(
                                      color: Colors.black54, width: 0.5))),
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.height * 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            // expands: true,
                            controller: _firstAnswerController,
                            cursorColor: Colors.black,
                            validator: (val) {
                              if (val.isEmpty) {
                                return '????????? ???????????????';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '?????? ??????',
                                hintStyle: TextStyle(
                                    fontFamily: 'Nanum', fontSize: 15)),
                            onChanged: (val) {
                              setState(() {
                                _firstAnswer = val;
                              });
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              _summitDate.weekday > 0 && _summitDate.weekday < 6
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('?????? 2. $_secondQuestion',
                                        style: TextStyle(
                                            fontFamily: 'Nanum',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width: MediaQuery.of(context).size.width * 1,
                                height: MediaQuery.of(context).size.height * 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller: _secondAnswerController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '????????? ???????????????';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '?????? ??????',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    setState(() {
                                      _secondAnswer = val;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              _summitDate.weekday > 0 && _summitDate.weekday < 6
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('?????? 3. $_thirdQuestion',
                                        style: TextStyle(
                                            fontFamily: 'Nanum',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width: MediaQuery.of(context).size.width * 1,
                                height: MediaQuery.of(context).size.height * 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller: _thirdAnswerController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '????????? ???????????????';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '?????? ??????',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    setState(() {
                                      _thirdAnswer = val;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              _summitDate.weekday > 0 && _summitDate.weekday < 6
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('?????? 4. $_fourthQuestion',
                                        style: TextStyle(
                                            fontFamily: 'Nanum',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width: MediaQuery.of(context).size.width * 1,
                                height: MediaQuery.of(context).size.height * 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller: _fourthAnswerController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '????????? ???????????????';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '?????? ??????',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    setState(() {
                                      _fourthAnswer = val;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              _summitDate.weekday > 0 && _summitDate.weekday < 6
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('?????? 5. $_fifthQuestion',
                                        style: TextStyle(
                                            fontFamily: 'Nanum',
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width: MediaQuery.of(context).size.width * 1,
                                height: MediaQuery.of(context).size.height * 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller: _fifthAnswerController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return '????????? ???????????????';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '?????? ??????',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Nanum', fontSize: 15)),
                                  onChanged: (val) {
                                    setState(() {
                                      _fifthAnswer = val;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              processing
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                        strokeWidth: 10,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        checkFeedPopup();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: Colors.black54, width: 0.5))),
                        child: Text('?????? ??????',
                            style: TextStyle(
                              fontFamily: 'Nanum',
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      )),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> deleteImage(String imageFileUrl) async {
  //   var fileUrl =
  //       Uri.decodeFull(imageFileUrl.replaceAll(new RegExp(r'(\?alt).*'), ''));
  //   final Reference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child(fileUrl);
  //   await firebaseStorageRef.delete();
  // }

  Future uploadImageToFirebase(BuildContext context) async {
    try {
      // ???????????? ????????? ????????? ????????? ?????? ?????? ?????? ?????????
      if (_imageChanged) {
        var todayMonth = _summitDate.month < 10
            ? '0' + _summitDate.month.toString()
            : _summitDate.month;
        var todayDay = _summitDate.day < 10
            ? '0' + _summitDate.day.toString()
            : _summitDate.day;

        // upload file ??????
        String fileName = 'image_${_summitDate.year}$todayMonth$todayDay';
        // upload ?????? ??????
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${currentUser.id}/$fileName');
        // upload ??????
        UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);

        // upload ??? state ??????
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
              'Snapshot state: ${snapshot.state}'); // paused, running, complete
          // print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
        }, onError: (Object e) {
          print(e); // FirebaseException
        });

        // upload ????????? ?????? url ?????? ???????????????
        uploadTask.then((TaskSnapshot taskSnapshot) {
          taskSnapshot.ref.getDownloadURL().then((value) {
            setState(() {
              _imageUrl = value;
            });
            // ???????????? ????????? (url ????????? ?????? ?????? ????????? ?????? ???)
            _summitDate.weekday > 0 && _summitDate.weekday < 6
                ? uploadDiary()
                : weekendUploadDiary();
            // uploadDiary();
          });
        });
      } else {
        // ?????? ?????? ?????? ????????? ?????? ?????? uploadDiary
        _summitDate.weekday > 0 && _summitDate.weekday < 6
            ? uploadDiary()
            : weekendUploadDiary();
        // uploadDiary();
      }
    } catch(e) {
      print(e);
    }
  }

  Future getCameraImage() async {
    final pickedFile = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 20);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future getGalleryImage() async {
    final pickedFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 5);

    setState(() {
      _imageFile = File(pickedFile.path);
      if (_imageUrl != null && _imageUrl != "" && _imageFile != null) {
        // ???????????? ???????????? ???????????? ???????????? ?????? ???
        _imageChanged = true;
      } else if (_imageFile != null) {
        _imageChanged = true;
      }
    });
  }

  weekendUploadDiary() {
    // batch ??????
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();

    var id = DateTime.now().microsecondsSinceEpoch.toString();
    // widget.diary => ????????? ????????? ????????? ??????????????? ?????? widget.diary ?????? ????????? ?????????.
    writeBatch.set(
        userReference
            .doc(currentUser.id)
            .collection('diarys')
            .doc(widget.diary != null ? widget.diary.id : id),
        {
          "id": widget.diary != null ? widget.diary.id : id,
          "profileUrl": currentUser.url != ""
              ? currentUser.url
              : "",
          "grade": currentUser.grade != null ? currentUser.grade : 1950,
          "userName":
              currentUser.userName != null ? currentUser.userName : "name",
          "firstQuestion": _firstQuestion,
          "firstAnswer": _firstAnswer,
          "imageUrl": _imageUrl != null && _imageUrl != "" ? _imageUrl : "",
          "summitDate": _summitDate,
          "createdAt": DateTime.now(),
          "isCompleteToFeed":
              widget.diary != null ? widget.diary.isCompleteToFeed : false,
        });

    if (widget.diary != null) {
      if (widget.diary.isCompleteToFeed)
        // Feed ????????? ??????
        writeBatch.update(
            FirebaseFirestore.instance.collection('feed').doc(widget.diary.id),
            {
              'firstAnswer': _firstAnswer,
              'imageUrl': _imageUrl != null ? _imageUrl : "",
              'updatedAt': DateTime.now()
            });
    }

    // batch end
    writeBatch.commit();

    showToast("?????? ?????? ??????");
  }

  uploadDiary() {
    // batch ??????
    WriteBatch writeBatch = FirebaseFirestore.instance.batch();

    var id = DateTime.now().microsecondsSinceEpoch.toString();
    // widget.diary => ????????? ????????? ????????? ??????????????? ?????? widget.diary ?????? ????????? ?????????.
    writeBatch.set(
        userReference
            .doc(currentUser.id)
            .collection('diarys')
            .doc(widget.diary != null ? widget.diary.id : id),
        {
          "id": widget.diary != null ? widget.diary.id : id,
          "profileUrl": currentUser.url != ""
              ? currentUser.url
              : "",
          "grade": currentUser.grade != null ? currentUser.grade : 1950,
          "userName":
              currentUser.userName != null ? currentUser.userName : "name",
          "firstQuestion": _firstQuestion,
          "firstAnswer": _firstAnswer,
          "secondQuestion": _secondQuestion,
          "secondAnswer": _secondAnswer,
          "thirdQuestion": _thirdQuestion,
          "thirdAnswer": _thirdAnswer,
          "fourthQuestion": _fourthQuestion,
          "fourthAnswer": _fourthAnswer,
          "fifthQuestion": _fifthQuestion,
          "fifthAnswer": _fifthAnswer,
          "imageUrl": _imageUrl != null && _imageUrl != "" ? _imageUrl : "",
          "summitDate": _summitDate,
          "createdAt": DateTime.now(),
          "isCompleteToFeed":
              widget.diary != null ? widget.diary.isCompleteToFeed : false,
        });

    if (widget.diary != null) {
      if (widget.diary.isCompleteToFeed)
        // Feed ????????? ??????
        writeBatch.update(
            FirebaseFirestore.instance.collection('feed').doc(widget.diary.id),
            {
              'firstAnswer': _firstAnswer,
              'secondAnswer': _secondAnswer,
              'thirdAnswer': _thirdAnswer,
              'fourthAnswer': _fourthAnswer,
              'fifthAnswer': _fifthAnswer,
              'imageUrl': _imageUrl != null ? _imageUrl : "",
              'updatedAt': DateTime.now()
            });
    }

    // batch end
    writeBatch.commit();

    showToast("?????? ?????? ??????");
  }

  checkFeedPopup() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('?????? ??????',
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black)),
            content: Text(
                "${_summitDate.toString().substring(0, 10)} ??? ?????????????\n????????? ???????????? ?????? ????????? ???????????????.",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('??????',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.black,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    // setState(() {
                    //   processing = true;
                    // });

                    uploadImageToFirebase(context);

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainPage(1)));
                    setState(() {
                      processing = false;
                    });
                  }
                },
              ),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('??????',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  alertNotCheckFuturePopup() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('?????? ??????',
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black)),
            content: Text("????????? ????????? ????????? ??? ????????????.",
                style: TextStyle(fontFamily: 'Nanum', color: Colors.black87)),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('??????',
                      style: TextStyle(
                          fontFamily: 'Nanum',
                          color: Colors.grey,
                          fontSize: 20)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _firstAnswerController.dispose();
    _secondAnswerController.dispose();
    _thirdAnswerController.dispose();
    _fourthAnswerController.dispose();
    _fifthAnswerController.dispose();
    super.dispose();
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
