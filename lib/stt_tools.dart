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

class SttTools {
  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    _initSpeech();
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
        srv = service;
      });

      service.on('setAsBackground').listen((event) async {
        service.setAsBackgroundService();
        srv = service;
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: this.appTitle,
          content: "Updated at ${DateTime.now()}",
        );
      }

      if (_speechEnabled) {
        _startListening();
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "last_message": _lastWords,
        },
      );
    });
  }
  String appTitle = "";
  SttTools(String appTitle) {
    this.appTitle = appTitle;
  }
  final service = FlutterBackgroundService();
  late ServiceInstance srv;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";

  Future initializeService() async {
    _initSpeech();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: (ServiceInstance service) {
          DartPluginRegistrant.ensureInitialized();
            _initSpeech();
          if (service is AndroidServiceInstance) {
            service.on('setAsForeground').listen((event) {
              service.setAsForegroundService();
              srv = service;
            });

            service.on('setAsBackground').listen((event) async {
              service.setAsBackgroundService();
              srv = service;
            });
          }

          service.on('stopService').listen((event) {
            service.stopSelf();
          });

          Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: this.appTitle,
                content: "Updated at ${DateTime.now()}",
              );
            }

            if (_speechEnabled) {
              _startListening();
            }

            service.invoke(
              'update',
              {
                "current_date": DateTime.now().toIso8601String(),
                "last_message": _lastWords,
              },
            );
          });
        },
        autoStart: false,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: (ServiceInstance service) {
          DartPluginRegistrant.ensureInitialized();
          _initSpeech();
          if (service is AndroidServiceInstance) {
            service.on('setAsForeground').listen((event) {
              service.setAsForegroundService();
              srv = service;
            });

            service.on('setAsBackground').listen((event) async {
              service.setAsBackgroundService();
              srv = service;
            });
          }

          service.on('stopService').listen((event) {
            service.stopSelf();
          });

          Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: this.appTitle,
                content: "Updated at ${DateTime.now()}",
              );
            }

            if (_speechEnabled) {
              _startListening();
            }

            service.invoke(
              'update',
              {
                "current_date": DateTime.now().toIso8601String(),
                "last_message": _lastWords,
              },
            );
          });
        },
        onBackground: onIosBackground,
      ),
    );
    await service.startService();
  }

  bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void stopListening() async {
    await _speechToText.stop();
    srv.stopSelf();
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    //var flutterTts = FlutterTts();
    _lastWords = (result.recognizedWords.toString().toLowerCase());
    print(_lastWords);
    /*if (_lastWords.contains("시작해")) {
      flutterTts.speak("Record start");
    } else if (_lastWords.contains('그만해')) {
      flutterTts.speak("Stopped");
    }*/
  }

  String getLastWords() {
    return _lastWords;
  }

}