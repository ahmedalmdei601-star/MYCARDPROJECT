import 'package:flutter/material.dart';
import '../services/card_services.dart';

class CardState extends ChangeNotifier {
  final CardService _cardService = CardService();
  List<Map<String, dynamic>> _clientCards = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get clientCards => _clientCards;
  bool get isLoading => _isLoading;

  Future<void> loadClientCards(String clientId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // جلب الكروت الموزعة للعميل
      final query = await _cardService.getClientCards(clientId);
      _clientCards = query;
    } catch (e) {
      debugPrint('Error loading client cards: $e');
      _clientCards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard({
    required String cardNumber,
    required String provider,
    required int value,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cardService.addCard(
        cardNumber: cardNumber,
        provider: provider,
        value: value,
      );
    } catch (e) {
      debugPrint('Error adding card: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addCardsBatch(
    List<String> codes,
    String provider,
    int value,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      int added = await _cardService.addCardsBatch(codes, provider, value);
      return added;
    } catch (e) {
      debugPrint('Error adding cards batch: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> distributeCards({
    required String clientId,
    required String provider,
    required int value,
    required int count,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cardService.distributeCards(
        clientId: clientId,
        provider: provider,
        value: value,
        count: count,
      );
    } catch (e) {
      debugPrint('Error distributing cards: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markCardAsUsed(
    String cardNumber,
    String customerPhone,
    String clientId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cardService.markCardAsUsed(cardNumber, customerPhone, clientId);
      // إعادة تحميل الكروت بعد التحديث
      await loadClientCards(clientId);
    } catch (e) {
      debugPrint('Error marking card as used: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
