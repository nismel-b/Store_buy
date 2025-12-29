import 'package:flutter/material.dart';
import 'package:store_buy/model/store_model.dart';
import 'package:store_buy/constants/app_colors.dart';

/// Widget pour afficher la bannière Open/Closed d'un magasin
class StoreStatusBanner extends StatelessWidget {
  final Store store;

  const StoreStatusBanner({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final isOpen = store.isCurrentlyOpen;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.success : AppColors.error,
        boxShadow: [
          BoxShadow(
            color: (isOpen ? AppColors.success : AppColors.error),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? 'OUVERT' : 'FERMÉ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          if (store.openingTime != null && store.closingTime != null) ...[
            const SizedBox(width: 8),
            Text(
              '(${store.openingTime} - ${store.closingTime})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

