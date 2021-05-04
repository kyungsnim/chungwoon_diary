import 'dart:io';
import 'dart:typed_data';

import 'package:church_diary_app/model/CurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:toast/toast.dart';

class MakePdfPage extends StatefulWidget {
  @override
  _MakePdfPageState createState() => _MakePdfPageState();
}

class _MakePdfPageState extends State<MakePdfPage> {
  var _lastRow = 0;
  final FETCH_ROW = 500;
  QuerySnapshot ds;
  bool isLoading;
  PdfDocument document = PdfDocument();
  Printing pt;
  var imageId = new List<dynamic>(200);
  var imageLoad = new List<dynamic>(200);
  List<Future<String>> imageDownloadPath = new List<Future<String>>(200);
  var imageDownloadAtStream;
  var pdfUploadAtStream;

  // Directory appDocDir;
  Stream<QuerySnapshot> userInfoStream;
  ScrollController _pdfScrollController = new ScrollController();

  // var finalImage;
  Uint8List imageBytes;
  List<List<dynamic>> imageBytesList = new List<List<dynamic>>(
      200); // 사용자 이미지 pdf에 넣기 위한 리스트 imageBytesList[사용자][일기]
  int index = 0;

  getUserStreamData() async {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('userName')
        .limit(FETCH_ROW * (_lastRow + 1))
        .snapshots();
  }

  getAllUserData() async {
    FirebaseFirestore.instance.collection('users').get().then((value) {
      setState(() {
        ds = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pdfScrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    // getAllUserData();
    getDirectoryPath(); // 일기 사진 다운받을 경로 지정
    getUserStreamData().then((val) {
      if (mounted) {
        setState(() {
          userInfoStream = val;
          isLoading = false;
        });
      }
    });
    _pdfScrollController.addListener(() {
      if (_pdfScrollController.position.pixels ==
          _pdfScrollController.position.maxScrollExtent) {
        setState(() => userInfoStream = getUserStreamData());
      }
    });
    for (int i = 0; i < 200; i++) {
      imageBytesList[i] = new List<dynamic>(200);
    }
  }

  getDirectoryPath() async {
    // appDocDir = await getApplicationDocumentsDirectory();
    // if (Platform.isIOS) {
    //   appDocDir = await getApplicationDocumentsDirectory();
    // } else {
    //   appDocDir = await getExternalStorageDirectory();
    // }
  }

  CurrentUser getUserModelFromDataSnapshot(
      DocumentSnapshot userInfoSnapshot, int index) {
    CurrentUser userModel = new CurrentUser(
      id: userInfoSnapshot.data()['id'],
      grade: userInfoSnapshot.data()['grade'],
      profileName: userInfoSnapshot.data()['profileName'],
      email: userInfoSnapshot.data()['email'],
      imageDownloadAt: userInfoSnapshot.data()['imageDownloadAt'] != null ? userInfoSnapshot.data()['imageDownloadAt'].toDate() : DateTime(1990,1,1),
      pdfUploadAt: userInfoSnapshot.data()['pdfUploadAt'] != null ? userInfoSnapshot.data()['pdfUploadAt'].toDate() : DateTime(1990,1,1)
    );
    return userModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Pdf 추출')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView(shrinkWrap: false, children: [
                    // searchUserInfo(),
                    viewUserInfoListStream(),
                  ]))
            // : Column(
            //     children: [
            //       Container(
            //           child: TextButton(
            //         child: Text('PDF'),
            //         onPressed: () async {
            //           // 로딩 시작
            //           setState(() {
            //             isLoading = true;
            //           });
            //
            //           final fontData =
            //               await rootBundle.load('fonts/NanumMyeongjo.ttf');
            //
            //           if (ds.size > 0) {
            //             // 모든 사용자 돌면서 pdf 저장시켜줘야 함
            //             for (int i = 0; i < 30; i++) {
            //               // ds.docs.length
            //               // 해당 사용자의 일기 데이터 불러오기
            //               ds.docs[i].reference
            //                   .collection('diarys')
            //                   .orderBy('summitDate')
            //                   .get()
            //                   .then((value) {
            //                 if (value.size > 0) {
            //                   try {
            //                     final pdf = pw.Document();
            //                     final ttf = pw.Font.ttf(fontData);
            //
            //                     // 일기별로 돌면서 pdf에 페이지 추가
            //                     for (int j = 0;
            //                         j < value.docs.length;
            //                         j++) {
            //                       var flag = false;
            //
            //                       if (value.docs[j].data()['imageUrl'] !=
            //                           "") {
            //                         var year = value.docs[j]
            //                             .data()['summitDate']
            //                             .toDate()
            //                             .toString()
            //                             .substring(0, 4);
            //                         var month = value.docs[j]
            //                             .data()['summitDate']
            //                             .toDate()
            //                             .toString()
            //                             .substring(5, 7);
            //                         var day = value.docs[j]
            //                             .data()['summitDate']
            //                             .toDate()
            //                             .toString()
            //                             .substring(8, 10);
            //                         var fileName =
            //                             'image_$year$month${day}_${ds.docs[i].data()['id']}';
            //                         Reference imageRef =
            //                             FirebaseStorage.instance.ref(
            //                                 '/uploads/${ds.docs[i].data()['id']}/image_$year$month$day');
            //
            //                         if (imageRef != null) {
            //                           File imageToFile = File(
            //                               '${appDocDir.path}/$fileName.jpg');
            //                           // imageBytes = imageToFile.readAsBytesSync();
            //                           setState(() {
            //                             // imageBytes = imageToFile.readAsBytesSync();
            //                             imageBytesList[i][j] = imageToFile
            //                                 .readAsBytesSync(); // 해당 사용자(i)의 일기(j)
            //                           });
            //                           flag =
            //                               true; // 사진이 있는 일기인 경우 flag 값 변경
            //                         }
            //                       }
            //                       var size =
            //                           MediaQuery.of(context).size.width *
            //                               0.5;
            //
            //                       pdf.addPage(pw.Page(
            //                           pageFormat: PdfPageFormat.a4,
            //                           build: (pw.Context context) {
            //                             return pw.Stack(children: [
            //                               pw.Column(
            //                                 crossAxisAlignment:
            //                                     pw.CrossAxisAlignment.start,
            //                                 mainAxisAlignment: pw.MainAxisAlignment.center,
            //                                 children: [
            //                                   // 사진이 있는 일기에만 사진 넣기
            //                                   flag
            //                                       ? pw.Center(child: pw.Image(pw.MemoryImage(
            //                                           imageBytesList[i][j]), width: 200, height: 200))
            //                                       // ? pw.Container(
            //                                       //     child: pw.Image(
            //                                       //         pw.MemoryImage(
            //                                       //             imageBytesList[
            //                                       //                 i][j]),
            //                                       //         fit: pw.BoxFit
            //                                       //             .cover),
            //                                       //     width: size)
            //                                       : pw.SizedBox(),
            //                                   pw.Text(value.docs[j]
            //                                       .data()['summitDate']
            //                                       .toDate()
            //                                       .toString()
            //                                       .substring(0, 10)),
            //                                   pw.SizedBox(height: 7),
            //                                   pw.Text(
            //                                       value.docs[j]
            //                                           .data()[
            //                                               'firstQuestion']
            //                                           .toString(),
            //                                       style: pw.TextStyle(
            //                                           font: ttf,
            //                                           fontSize: 10,
            //                                           fontWeight: pw
            //                                               .FontWeight
            //                                               .bold)),
            //                                   pw.Divider(thickness: 0.5),
            //                                   pw.Text(
            //                                       value.docs[j]
            //                                           .data()['firstAnswer']
            //                                           .toString(),
            //                                       style: pw.TextStyle(
            //                                           font: ttf,
            //                                           fontSize: 9)),
            //                                   pw.Divider(thickness: 0.5),
            //                                   pw.SizedBox(height: 5),
            //                                   value.docs[j].data()[
            //                                               'secondQuestion'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'secondQuestion'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 10))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'secondQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'secondAnswer'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'secondAnswer'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 9))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'secondQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'secondQuestion'] !=
            //                                           null
            //                                       ? pw.SizedBox(height: 5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'thirdQuestion'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'thirdQuestion'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 10))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'thirdQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'thirdAnswer'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'thirdAnswer'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 9))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'thirdQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'thirdQuestion'] !=
            //                                           null
            //                                       ? pw.SizedBox(height: 5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fourthQuestion'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'fourthQuestion'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 10))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fourthQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fourthAnswer'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'fourthAnswer'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 9))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fourthQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fourthQuestion'] !=
            //                                           null
            //                                       ? pw.SizedBox(height: 5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fifthQuestion'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'fifthQuestion'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 10))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fifthQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fifthAnswer'] !=
            //                                           null
            //                                       ? pw.Text(
            //                                           value.docs[j].data()[
            //                                               'fifthAnswer'],
            //                                           style: pw.TextStyle(
            //                                               font: ttf,
            //                                               fontSize: 9))
            //                                       : pw.SizedBox(),
            //                                   value.docs[j].data()[
            //                                               'fifthQuestion'] !=
            //                                           null
            //                                       ? pw.Divider(
            //                                           thickness: 0.5)
            //                                       : pw.SizedBox(),
            //                                 ],
            //                               ),
            //                             ]); // Center
            //                           })); // Page
            //                     }
            //                     savePdf(
            //                         pdf,
            //                         ds.docs[i].data()['grade'].toString() +
            //                             ' ' +
            //                             ds.docs[i].data()['profileName']);
            //                     // pdf 업로드하기
            //                   } catch (e) {
            //                     print(e);
            //                   }
            //                 }
            //               });
            //             }
            //           }
            //
            //           // 로딩 끝
            //           setState(() {
            //             isLoading = false;
            //           });
            //         },
            //         // onPressed: createPdf,
            //       )),
            //       TextButton(
            //           onPressed: () async {
            //             try {
            //               // 로딩 시작
            //               setState(() {
            //                 isLoading = true;
            //               });
            //
            //               if (ds.size > 0) {
            //                 // 모든 사용자 돌면서 pdf 저장시켜줘야 함
            //                 for (int i = 0; i < 30; i++) {
            //                   // ds.docs.length
            //                   // diary 데이터 불러오기
            //                   ds.docs[i].reference
            //                       .collection('diarys')
            //                       .get()
            //                       .then((value) {
            //                     if (value.size > 0) {
            //                       try {
            //                         // 일기별로 돌면서 pdf에 페이지 추가
            //                         for (int j = 0;
            //                             j < value.docs.length;
            //                             j++) {
            //                           // 다운로드 받을 폴더 경로 지정
            //                           if (value.docs[j]
            //                                   .data()['imageUrl'] !=
            //                               "") {
            //                             var year = value.docs[j]
            //                                 .data()['summitDate']
            //                                 .toDate()
            //                                 .toString()
            //                                 .substring(0, 4);
            //                             var month = value.docs[j]
            //                                 .data()['summitDate']
            //                                 .toDate()
            //                                 .toString()
            //                                 .substring(5, 7);
            //                             var day = value.docs[j]
            //                                 .data()['summitDate']
            //                                 .toDate()
            //                                 .toString()
            //                                 .substring(8, 10);
            //                             // var fileName = 'image_$year$month$day';
            //                             var fileName =
            //                                 'image_$year$month${day}_${ds.docs[i].data()['id']}';
            //                             Reference imageRef =
            //                                 FirebaseStorage.instance.ref(
            //                                     '/uploads/${ds.docs[i].data()['id']}/image_$year$month$day');
            //
            //                             downloadFileExample(
            //                                 imageRef, fileName);
            //                           }
            //                         }
            //                         // pdf 업로드하기
            //                       } catch (e) {
            //                         print(e);
            //                       }
            //                     }
            //                   });
            //                 }
            //               }
            //               showToast("이미지 다운로드 완료");
            //
            //               // 로딩 끝
            //               setState(() {
            //                 isLoading = false;
            //               });
            //             } on PlatformException catch (error) {
            //               print(error);
            //             }
            //           },
            //           child: Text('image download All')),
            //     ],
            //   ),
          ]),
        ));
  }

  viewUserInfoListStream() {
    return userInfoStream != null
        ? Scrollbar(
            child: StreamBuilder<QuerySnapshot>(
                stream: userInfoStream,
                builder: (context, stream) {
                  if (stream.hasError) {
                    return Center(child: Text(stream.error.toString()));
                  }

                  QuerySnapshot querySnapshot = stream.data;

                  if (!stream.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      strokeWidth: 10,
                    ));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      controller: _pdfScrollController,
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        final currentRow = (index + 1) ~/ FETCH_ROW;
                        if (_lastRow != currentRow) {
                          _lastRow = currentRow;
                        }
                        return UserInfoTile(
                          searchUser: getUserModelFromDataSnapshot(
                              querySnapshot.docs[index], index),
                          index: index,
                        );
                      },
                    );
                  }
                }))
        : CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
          );
  }

  // Future<void> downloadFileExample(Reference ref, String fileName) async {
  //   print(
  //       '&&&&&&&&&& appDocDir: ${appDocDir.path}'); // getApplicationDocumentsDirectory()
  //   File downloadToFile = File('${appDocDir.path}/$fileName.jpg');
  //   File finalImage = await File('${appDocDir.path}/$fileName.jpg').create();
  //
  //   try {
  //     final DownloadTask task = ref.writeToFile(downloadToFile);
  //     await task.whenComplete(() {
  //       // showToast("이미지 다운로드 완료");
  //     });
  //   } on FirebaseException catch (e) {
  //     // e.g, e.code == 'canceled'
  //   }
  // }

  savePdf(pdf, userName) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$userName.pdf");
    await file.writeAsBytes(await pdf.save());

    Reference diaryRef =
        FirebaseStorage.instance.ref().child('diarys/$userName.pdf');
    // // upload Task는 제공되나 아직 실제 업로드 전
    UploadTask uploadTask = diaryRef.putFile(file);
    // 실제 파일 업로드 (중간에 중단, 취소 등 하지 않을 것이므로 최대한 심플하게 가보자.)
    await uploadTask
        .whenComplete(() => showToast('$userName 파일 업로드 완료', duration: 2));
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}

class UserInfoTile extends StatefulWidget {
  final CurrentUser searchUser;
  final int index;

  UserInfoTile({this.searchUser, this.index});

  @override
  _UserInfoTileState createState() => _UserInfoTileState();
}

class _UserInfoTileState extends State<UserInfoTile> {
  var isLoading = false;
  Directory appDocDir;
  var diaryCount, imageCount = 0;
  List<dynamic> imageBytesList = new List<dynamic>(
      200); // 사용자 이미지 pdf에 넣기 위한 리스트 imageBytesList[사용자][일기]

  @override
  void initState() {
    super.initState();
    getDirectoryPath();
  }

  getDirectoryPath() async {
    // appDocDir = await getApplicationDocumentsDirectory();
    if (Platform.isIOS) {
      appDocDir = await getApplicationDocumentsDirectory();
    } else {
      appDocDir = await getExternalStorageDirectory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: ListTile(
        tileColor: Colors.blueGrey.withOpacity(0.2),
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  widget.searchUser.imageDownloadAt == DateTime(1990,1,1) ? Text("") : Text('이미지다운 : ${widget.searchUser.imageDownloadAt.month}/${widget.searchUser.imageDownloadAt.day} ${widget.searchUser.imageDownloadAt.hour}:${widget.searchUser.imageDownloadAt.minute}'),
                  SizedBox(height: 2),
                  widget.searchUser.pdfUploadAt == DateTime(1990,1,1) ? Text("") : Text('pdf업로드 : ${widget.searchUser.pdfUploadAt.month}/${widget.searchUser.pdfUploadAt.day} ${widget.searchUser.pdfUploadAt.hour}:${widget.searchUser.pdfUploadAt.minute}'),
                ],
              ),
              Spacer(),
              RaisedButton(
                color: Colors.black,
                onPressed: () async {
                  try {
                    // 로딩 시작
                    setState(() {
                      isLoading = true;
                    });



                    // diary 데이터 불러오기
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.searchUser.id)
                        .collection('diarys')
                        .get()
                        .then((value) {
                      if (value.size > 0) {
                        setState(() {
                          diaryCount = value.size;
                        });
                        try {
                          // 다이어리 이미지 있는 경우 다운로드
                          for (int j = 0; j < value.docs.length; j++) {
                            if (value.docs[j].data()['imageUrl'] != "") {
                              setState(() {
                                imageCount++;
                              });

                              var year = value.docs[j]
                                  .data()['summitDate']
                                  .toDate()
                                  .toString()
                                  .substring(0, 4);
                              var month = value.docs[j]
                                  .data()['summitDate']
                                  .toDate()
                                  .toString()
                                  .substring(5, 7);
                              var day = value.docs[j]
                                  .data()['summitDate']
                                  .toDate()
                                  .toString()
                                  .substring(8, 10);
                              // var fileName = 'image_$year$month$day';
                              var fileName =
                                  'image_$year$month${day}_${widget.searchUser.id}';
                              Reference imageRef = FirebaseStorage.instance.ref(
                                  '/uploads/${widget.searchUser.id}/image_$year$month$day');

                              downloadImage(imageRef, fileName);
                            }
                          }
                          FirebaseFirestore.instance.collection('users').doc(widget.searchUser.id).update(
                              {
                                'imageDownloadAt' : DateTime.now()
                              });
                          // pdf 업로드하기
                        } catch (e) {
                          print(e);
                        }
                      }
                    });



                    // 로딩 끝
                    setState(() {
                      isLoading = false;

                    });
                  } on PlatformException catch (error) {
                    print(error);
                  }
                },
                child: Icon(
                  Icons.cloud_download_sharp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5),
              RaisedButton(
                color: Colors.black,
                onPressed: () async {
                            // 로딩 시작
                            setState(() {
                              isLoading = true;
                            });

                            final fontData =
                                await rootBundle.load('fonts/NanumMyeongjo.ttf');

                                // 해당 사용자의 일기 데이터 불러오기
                                FirebaseFirestore.instance.collection('users').doc(widget.searchUser.id)
                                    .collection('diarys')
                                    .orderBy('summitDate')
                                    .get()
                                    .then((value) {
                                  if (value.size > 0) {
                                    print('>>>>>>>>>>>> value.size : ${value.size}');
                                    try {
                                      final pdf = pw.Document();
                                      final ttf = pw.Font.ttf(fontData);

                                      // 일기별로 돌면서 pdf에 페이지 추가
                                      for (int j = 0;
                                          j < value.docs.length;
                                          j++) {
                                        var flag = false;

                                        if (value.docs[j].data()['imageUrl'] !=
                                            "") {
                                          var year = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(0, 4);
                                          var month = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(5, 7);
                                          var day = value.docs[j]
                                              .data()['summitDate']
                                              .toDate()
                                              .toString()
                                              .substring(8, 10);
                                          var fileName =
                                              'image_$year$month${day}_${widget.searchUser.id}';
                                          Reference imageRef =
                                              FirebaseStorage.instance.ref(
                                                  '/uploads/${widget.searchUser.id}/image_$year$month$day');

                                          if (imageRef != null) {
                                            File imageToFile = File(
                                                '${appDocDir.path}/$fileName.jpg');
                                            // imageBytes = imageToFile.readAsBytesSync();
                                            setState(() {
                                              // imageBytes = imageToFile.readAsBytesSync();
                                              imageBytesList[j] = imageToFile
                                                  .readAsBytesSync(); // 해당 사용자(i)의 일기(j)
                                            });
                                            flag =
                                                true; // 사진이 있는 일기인 경우 flag 값 변경
                                          }
                                        }
                                        var size =
                                            MediaQuery.of(context).size.width *
                                                0.5;

                                        pdf.addPage(pw.Page(
                                            pageFormat: PdfPageFormat.a4,
                                            build: (pw.Context context) {
                                              return pw.Stack(children: [
                                                pw.Column(
                                                  crossAxisAlignment:
                                                      pw.CrossAxisAlignment.start,
                                                  mainAxisAlignment: pw.MainAxisAlignment.center,
                                                  children: [
                                                    // 사진이 있는 일기에만 사진 넣기
                                                    flag
                                                        ? pw.Center(child: pw.Image(pw.MemoryImage(
                                                            imageBytesList[j]), width: 200, height: 200))
                                                        // ? pw.Container(
                                                        //     child: pw.Image(
                                                        //         pw.MemoryImage(
                                                        //             imageBytesList[
                                                        //                 i][j]),
                                                        //         fit: pw.BoxFit
                                                        //             .cover),
                                                        //     width: size)
                                                        : pw.SizedBox(),
                                                    pw.Text(value.docs[j]
                                                        .data()['summitDate']
                                                        .toDate()
                                                        .toString()
                                                        .substring(0, 10)),
                                                    pw.SizedBox(height: 7),
                                                    pw.Text(
                                                        value.docs[j]
                                                            .data()[
                                                                'firstQuestion']
                                                            .toString(),
                                                        style: pw.TextStyle(
                                                            font: ttf,
                                                            fontSize: 10,
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                    pw.Divider(thickness: 0.5),
                                                    pw.Text(
                                                        value.docs[j]
                                                            .data()['firstAnswer']
                                                            .toString(),
                                                        style: pw.TextStyle(
                                                            font: ttf,
                                                            fontSize: 9)),
                                                    pw.Divider(thickness: 0.5),
                                                    pw.SizedBox(height: 5),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'secondQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'secondAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 9))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'secondQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'thirdQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'thirdAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 9))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'thirdQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'fourthQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'fourthAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 9))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fourthQuestion'] !=
                                                            null
                                                        ? pw.SizedBox(height: 5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'fifthQuestion'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 10))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthAnswer'] !=
                                                            null
                                                        ? pw.Text(
                                                            value.docs[j].data()[
                                                                'fifthAnswer'],
                                                            style: pw.TextStyle(
                                                                font: ttf,
                                                                fontSize: 9))
                                                        : pw.SizedBox(),
                                                    value.docs[j].data()[
                                                                'fifthQuestion'] !=
                                                            null
                                                        ? pw.Divider(
                                                            thickness: 0.5)
                                                        : pw.SizedBox(),
                                                  ],
                                                ),
                                              ]); // Center
                                            })); // Page
                                      }
                                      var tmpGrade = widget.searchUser.grade != null ? widget.searchUser.grade.toString() : "";
                                      var tmpUserName = widget.searchUser.userName != null ? widget.searchUser.userName.toString() : "";
                                      var tmpProfileName = widget.searchUser.profileName != null ? widget.searchUser.profileName : "";
                                      var tmpEmail = widget.searchUser.email;

                                      var pdfFileName = '$tmpGrade $tmpUserName $tmpProfileName $tmpEmail';

                                      savePdf(
                                          pdf,
                                          pdfFileName);

                                      FirebaseFirestore.instance.collection('users').doc(widget.searchUser.id).update(
                                          {
                                            'pdfUploadAt' : DateTime.now()
                                          });
                                      // pdf 업로드하기
                                    } catch (e) {
                                      print(e);
                                    }
                                  }
                                });

                            // 로딩 끝
                            setState(() {
                              isLoading = false;
                            });
                          },
                child: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.searchUser.grade == null
                  ? ""
                  : widget.searchUser.grade.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Spacer(),
            Text(
              widget.searchUser.profileName == null
                  ? ""
                  : widget.searchUser.profileName.length > 15
                      ? widget.searchUser.profileName.substring(0, 15)
                      : widget.searchUser.profileName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Spacer(),
            Text(
              widget.searchUser.email == null ? "" : widget.searchUser.email,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadImage(Reference ref, String fileName) async {
    // print(
        // '&&&&&&&&&& appDocDir: ${appDocDir.path}'); // getApplicationDocumentsDirectory()
    File downloadToFile = File('${appDocDir.path}/$fileName.jpg');
    File finalImage = await File('${appDocDir.path}/$fileName.jpg').create();

    try {
      final DownloadTask task = ref.writeToFile(downloadToFile);
      await task.whenComplete(() {
        // showToast("이미지 다운로드 완료");
        showToast("일기 $diaryCount개, 이미지 $imageCount개 다운로드 완료");
      });
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  savePdf(pdf, userName) async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$userName.pdf");
    await file.writeAsBytes(await pdf.save());
    Reference diaryRef =
    FirebaseStorage.instance.ref().child('diarys/$userName.pdf');
    // // upload Task는 제공되나 아직 실제 업로드 전
    UploadTask uploadTask = diaryRef.putFile(file);
    // 실제 파일 업로드 (중간에 중단, 취소 등 하지 않을 것이므로 최대한 심플하게 가보자.)
    await uploadTask
        .whenComplete(() => showToast('$userName 파일 업로드 완료', duration: 2));
  }

  showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
