import 'package:flutter/material.dart';

class ProfessionalModel {
  final String name;
  final String specialty;
  final String rating;
  final bool isOnline;
  final String? imageUrl;           // Para imágenes de red
  final ImageProvider? imageProvider; // Para imágenes locales (AssetImage, FileImage, etc.)

  ProfessionalModel({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.isOnline,
    this.imageUrl,
    this.imageProvider,
  }) : assert(imageUrl != null || imageProvider != null, 
           'Debe proporcionar imageUrl o imageProvider');
}