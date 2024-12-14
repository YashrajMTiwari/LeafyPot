import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class DetectionService {
  final Dio _dio = Dio();
  final String healthApiUrl = "http://192.168.130.172:8080/image";
  final String moistureApiUrl = "http://192.168.130.172:8080/moisture_level";
 // For jsonDecode

  Future<Map<String, dynamic>> healthDetection(File image) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      Response response = await _dio.post(
        healthApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        var predictionData = response.data['prediction'];
        if (predictionData is String) {
          predictionData = {'status': predictionData};
        }
        if (predictionData is Map<String, dynamic>) {
          print(predictionData);
          return predictionData;
        } else {
          throw Exception('--> Unexpected prediction format: ${predictionData.runtimeType}');
        }
      } else {
        throw Exception('--> Failed to detect plant health. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('--> Error in health detection: $e');
      rethrow;
    }
  }



  Timer? _timer;

  Future<Map<String, dynamic>> _fetchMoistureData() async {
    try {
      Response response = await _dio.get(
        moistureApiUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print('--> API Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('--> Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('--> Error in fetching moisture data: $e');
      return {};
    }
  }
  Future<void> _updateMoistureForPlant(String plantId, Map<String, dynamic> moistureData) async {
    try {
      int moistureLevel = moistureData['sensor_value'] ?? 0;
      await FirebaseFirestore.instance.collection('plants').doc(plantId).update({
        'plant_mos': moistureLevel,
      });

      print('--> Updated moisture data for plant $plantId in Firebase.');
    } catch (e) {
      print('--> Error in updating moisture data for plant $plantId: $e');
    }
  }


  Future<void> updateMoistureForAllPlants() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print('--> No user is logged in');
        return;
      }

      QuerySnapshot plantSnapshots = await FirebaseFirestore.instance
          .collection('plants')
          .where('user_id', isEqualTo: userId)
          .get();

      if (plantSnapshots.docs.isEmpty) {
        print('--> No plants found for the current user.');
        return;
      }

      Map<String, dynamic> moistureData = await _fetchMoistureData();
      if (moistureData.isEmpty) {
        print('--> No moisture data received from the API.');
        return;
      }

      for (var plant in plantSnapshots.docs) {
        String plantId = plant.id;
        await _updateMoistureForPlant(plantId, moistureData);
      }

      print('--> All plants updated with new moisture data.');
    } catch (e) {
      print('--> Error updating moisture for all plants: $e');
    }
  }

  void startBackgroundProcess() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      print('--> Running periodic moisture detection... ');
      await updateMoistureForAllPlants();
    });
  }

  void stopBackgroundProcess() {
    _timer?.cancel();
    print('--> Background process stopped.');
  }
}


// If Things Stop Working

/*
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';

class DetectionService {
  final Dio _dio = Dio();
  final String healthApiUrl = "http://192.168.1.104:8001/image";
  final String moistureApiUrl = "http://192.168.1.104:8001/moisture";

  Future<Map<String, dynamic>> healthDetection(File image) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      Response response = await _dio.post(
        healthApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to detect plant health. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error in health detection: $e');
      rethrow;
    }
  }

/*
  Future<Map<String, dynamic>> moistureDetection(File image) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      Response response = await _dio.post(
        moistureApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to detect moisture level. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in moisture detection: $e');
      rethrow;
    }
  }
*/

  Timer? _timer;
  Future<Map<String, dynamic>> _fetchMoistureData() async {
    try {
      Response response = await _dio.get(
        moistureApiUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.data}');
        return response.data; // Assuming the response is a map
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetching moisture data: $e');
      return {}; // Return an empty map in case of error
    }
  }

  Future<void> _updateFirebaseData(Map<String, dynamic> moistureData) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print('No user is logged in');
        return;
      }

      await FirebaseFirestore.instance.collection('plants').doc(userId).set(
        {
          'plant_mos': moistureData,
        },
        SetOptions(merge: true),
      );

      print('Firebase updated successfully with moisture data.');
    } catch (e) {
      print('Error in updating Firebase: $e');
    }
  }

  void startBackgroundProcess() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      print('Running moisture detection...');

      Map<String, dynamic> moistureData = await _fetchMoistureData();

      if (moistureData.isNotEmpty) {
        await _updateFirebaseData(moistureData);
      }
    });
  }
  void stopBackgroundProcess() {
    _timer?.cancel();
    print('Background process stopped.');
  }
}
 */

