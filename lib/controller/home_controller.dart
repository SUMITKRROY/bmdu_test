import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class HomeController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? userName;
  String? userEmail;
  String? fcmToken;

  double? latitude;
  double? longitude;
  String currentAddress = "Current Address";

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
      developer.log('latitude: $latitude, longitude: $longitude');

      await _getAddress();
    } catch (e) {
      developer.log('Error fetching location: $e');
    }
  }

  Future<void> _getAddress() async {
    try {
      if (latitude != null && longitude != null) {
        List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude!, longitude!);
        Placemark place = placemarks[0];
        currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        developer.log('Address: $currentAddress');
      }
    } catch (e) {
      developer.log('Error fetching address: $e');
    }
  }

  Future<void> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    fcmToken = await messaging.getToken();
    developer.log("FCM Token: $fcmToken");
  }

  Future<void> handleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        userName = account.displayName;
        userEmail = account.email;
      }
    } catch (error) {
      developer.log('Error signing in: $error');
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      userName = null;
      userEmail = null;
    } catch (error) {
      developer.log('Error signing out: $error');
    }
  }

  Future<void> sendNotification(String title, String body) async {
    const serverKey = 'YOUR_SERVER_KEY'; // Replace with your FCM server key
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );

      if (response.statusCode == 200) {
        developer.log('Notification sent successfully');
      } else {
        developer.log('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      developer.log('Error sending notification: $e');
    }
  }
}
