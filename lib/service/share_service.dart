import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service pour partager des liens vers les magasins
class ShareService {
  /// Partager un lien vers un magasin
  Future<void> shareStoreLink({
    required String storeId,
    required String storeName,
  }) async {
    // In a real app, this would be a deep link or web URL
    final link = 'store_buy://store/$storeId';
    final text = 'Découvrez le magasin $storeName sur Store Self!\n$link';
    
    await Share.share(text);
  }

  /// Partager sur les réseaux sociaux
  Future<void> shareOnSocialMedia({
    required String storeId,
    required String storeName,
    required String platform, // 'facebook', 'twitter', 'whatsapp'
  }) async {
    final link = 'store_buy://store/$storeId';
    final text = 'Découvrez le magasin $storeName sur Store Self!';
    
    String url = '';
    switch (platform) {
      case 'facebook':
        url = 'https://www.facebook.com/sharer/sharer.php?u=$link';
        break;
      case 'twitter':
        url = 'https://twitter.com/intent/tweet?text=$text&url=$link';
        break;
      case 'whatsapp':
        url = 'https://wa.me/?text=$text%20$link';
        break;
    }

    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}


