import 'package:flutter/material.dart';

enum Category{
  freshProduct,
  accessoire,
  electromenager,
  vetementTextile,
  materielScolaire,
  ustensile,
  cosmetique,
  meche,
  shoes,
  bijoux,
  construction,
  hygiene,
  luminaire,
  literieMeuble,
  bazar,
  restauration,
}

class Store {
  final String? storeId;
  final String? userId;
  final String storename;
  final Category category;
  final String description;
  final String slogan;
 // final String regle;
  final String password;
  final String adresse;
  final String photo;
  final String code; //pour permettre à d'autres personnes de se connecter au magasin
  final String? openingTime; // Format: "HH:mm" (ex: "08:00")
  final String? closingTime; // Format: "HH:mm" (ex: "18:00")
  final bool isOpen; // Statut actuel (ouvert/fermé)

  Store({
    this.storeId,
    this.userId,
    required this.storename,
    required this.category,
    required this.description,
    required this.slogan,
    //required this.regle,
    required this.password,
    required this.adresse,
    required this.photo,
    required this.code,
    this.openingTime,
    this.closingTime,
    this.isOpen = true,
  });

  /// Vérifier si le magasin est actuellement ouvert
  bool get isCurrentlyOpen {
    if (!isOpen) return false;
    if (openingTime == null || closingTime == null) return true;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final opening = _parseTime(openingTime!);
    final closing = _parseTime(closingTime!);
    
    if (opening == null || closing == null) return true;
    
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openingMinutes = opening.hour * 60 + opening.minute;
    final closingMinutes = closing.hour * 60 + closing.minute;
    
    return currentMinutes >= openingMinutes && currentMinutes <= closingMinutes;
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  bool get isfreshProduct => category == Category.freshProduct;
  bool get isaccessoire => category == Category.accessoire;
  bool get iselectromenager => category == Category.electromenager;
  bool get isvetementTextile => category == Category.vetementTextile;
  bool get ismaterielScolaire => category == Category.materielScolaire;
  bool get isustensile => category == Category.ustensile;
  bool get iscosmetique => category == Category.cosmetique;
  bool get ismeche => category == Category.meche;
  bool get isshoes => category == Category.shoes;
  bool get isbijoux => category == Category.bijoux;
  bool get isconstruction => category == Category.construction;
  bool get ishygiene => category == Category.hygiene;
  bool get luminaire=> category == Category.luminaire;
  bool get literieMeuble => category == Category.literieMeuble;
  bool get bazar => category == Category.bazar;
  bool get isrestauration => category == Category.restauration;


}