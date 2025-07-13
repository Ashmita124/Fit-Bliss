import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void handleSupabaseError(dynamic error) {
  String message = "Something went wrong. Please try again.";

  if (error is AuthException) {
    message = _parseMessage(error.message);
  } else if (error is PostgrestException) {
    message = _parseMessage(error.message);
  } else if (error is StorageException) {
    message = _parseMessage(error.message);
  } else if (error is String) {
    message = _parseMessage(error);
  } else if (error is Exception) {
    message = _parseMessage(error.toString());
  }

  Get.snackbar(
    "Error",
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.shade100,
    colorText: Colors.black,
    duration: const Duration(seconds: 4),
  );
}

String _parseMessage(String rawMessage) {
  final lower = rawMessage.toLowerCase();

  if (lower.contains("invalid login credentials")) {
    return "Incorrect email or password.";
  } else if (lower.contains("email") && lower.contains("exists")) {
    return "An account with this email already exists.";
  } else if (lower.contains("email") && lower.contains("not confirmed")) {
    return "Email not confirmed. Please check your inbox.";
  } else if (lower.contains("invalid email")) {
    return "Please enter a valid email address.";
  } else if (lower.contains("password") && lower.contains("short")) {
    return "Password is too short.";
  } else if (lower.contains("network") || lower.contains("socket")) {
    return "Network error. Please check your connection.";
  } else if (lower.contains("too many requests") ||
      lower.contains("rate limit")) {
    return "Too many requests. Please wait and try again.";
  } else if (lower.contains("jwt expired") || lower.contains("token")) {
    return "Session expired. Please log in again.";
  } else if (lower.contains("permission") || lower.contains("unauthorized")) {
    return "You don't have permission to perform this action.";
  } else if (lower.contains("not found")) {
    return "Requested resource not found.";
  }

  return rawMessage; // fallback to raw message if no friendly match
}
