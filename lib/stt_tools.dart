import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:flutter_background_service/flutter_background_service.dart'
    show
        AndroidConfiguration,
        FlutterBackgroundService,
        IosConfiguration,
        ServiceInstance;

// ignore_for_file: depend_on_referenced_packages
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttValues {
  String lastWords = "";
  bool onListen = false;
}

class SttTools extends ChangeNotifier {
  void start() {
    if (!_speechEnabled) {
      _initSpeech();
    }
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (onListen && _speechEnabled) {
        _startListening();
      }
    });
  }
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool onListen = false;
  final SttValues sttValues = SttValues();

  String lastWords = "";

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void restart() async {
    onListen = true;
    sttValues.onListen = onListen;
    if (!_speechEnabled) {
      start();
    }
    notifyListeners();
  }

  void pause() async {
    onListen = false;
    sttValues.onListen = onListen;
    notifyListeners();
  }

  void stop() async {
    await _speechToText.stop();
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    //var flutterTts = FlutterTts();
    String text = result.recognizedWords.toString().toLowerCase();
    if (text.isNotEmpty) {
      lastWords = text;
      sttValues.lastWords = lastWords;
      notifyListeners();
    }
    print(lastWords);
    /*if (_lastWords.contains("시작해")) {
      flutterTts.speak("Record start");
    } else if (_lastWords.contains('그만해')) {
      flutterTts.speak("Stopped");
    }*/
  }
}