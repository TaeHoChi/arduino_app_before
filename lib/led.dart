// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'customWiget/custom_image.dart';
import 'customWiget/downtextfont.dart';
import 'customWiget/park_container.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;
  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        //예: 어느 쪽이 연결을 닫았는지 감지
        // 우리가 (로컬)인지 표시하려면 `isDisconnecting` 플래그가 있어야 합니다.
        // 연결 끊기 과정 중, 호출하기 전에 설정해야 함
        // `dispose`, `finish` 또는 `close`, 모두 연결을 끊습니다.
        // 연결 끊김을 제외하면 결과적으로 'onDone'이 실행되어야 합니다.
        // 이것을 제외하고(플래그 설정 없음), 원격으로 닫는 것을 의미합니다.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // 메모리 누수 방지(dispose 후 `setState`) 및 연결 해제
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  List<_Message> ricevetext = List<_Message>();

  double _value = 90.0;
  @override
  Widget build(BuildContext context) {
    //메세지를 표현하기 위한 장치
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  if (_message.whom == clientID) {
                    return text == '0' ? '문이 열립니다.' : '문이 닫힙니다.';
                  }
                  if (_message.whom == 1) {
                    return text == '2'
                        ? '1번에 주차완료'
                        : text == '3'
                            ? '2번에 주차완료'
                            : text == '4'
                                ? '3번에 주차완료'
                                : text == '5'
                                    ? '4번에 주차완료'
                                    : text == '6'
                                        ? '5번에 주차완료'
                                        : text;
                  }
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                // user / device 구분
                color: _message.whom == clientID
                    ? Colors.blueAccent
                    : Color.fromARGB(255, 75, 53, 134),
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 75, 53, 134),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: ((context, setState) {
                  return AlertDialog(
                    backgroundColor: Color.fromARGB(255, 183, 183, 183),
                    content: Form(
                      child: Container(
                        height: 350,
                        child: Column(
                          children: [
                            Text(
                              '주차도',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                parkContainer("1"),
                                parkContainer("2"),
                                parkContainer("3"),
                              ],
                            ),

                            //하단 주차장
                            Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  parkContainer('5'),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  parkContainer('6'),
                                ],
                              ),
                            ),

                            //입구 출구 아이콘 및 디자인
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: SizedBox(
                                width: 350,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomImage('images/downarrow.png', '출구'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    CustomImage('images/upward.png', '입구')
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }));
              });
        },
        child: Icon(
          Icons.local_parking,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 12,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        color: Color.fromARGB(255, 75, 53, 134),
      ),
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 75, 53, 134),
          title: (isConnecting
              ? Text(widget.server.name + ' 연결 중...')
              : isConnected
                  ? Text(widget.server.name + ' 연결했습니다')
                  : Text(widget.server.name + ' 연결이 되지않았습니다'))),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color.fromARGB(255, 212, 212, 212),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //메시지 출력
                Flexible(
                  child: ListView(
                      padding: const EdgeInsets.all(12.0),
                      controller: listScrollController,
                      children: list),
                ),

                //하단 내용
                Column(
                  children: [
                    Container(
                      color: Color.fromARGB(255, 75, 53, 134),
                      height: 50,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15, left: 20),
                        child: Text(
                          '정보',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            down_TextFont('주차장', '명지 전문대'),
                            SizedBox(height: 5),
                            down_TextFont('위치', '경기도 '),
                            SizedBox(height: 5),
                            down_TextFont('요금', '10,000'),
                            //문열기 버튼
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: TextButton(
                                        onPressed: () {
                                          _sendMessage('0');
                                        },
                                        child: const Text(
                                          '문 열기',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: 100,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: TextButton(
                                        onPressed: () {
                                          _sendMessage('1');
                                        },
                                        child: const Text(
                                          '문 닫기',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // 파싱된 데이터를 위한 버퍼 할당
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // 백스페이스 제어 문자 적용
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // 개행 문자가 있는 경우 메시지 작성
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  //앱에서 아두이노에게 값을 보낸다
  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
