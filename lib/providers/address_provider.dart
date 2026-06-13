// lib/providers/address_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [];
  AddressModel? _selected;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _selected;

  void addAddress(AddressModel address) {
    if (address.isDefault) {
      // Remove default from others
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    _selected ??= address;
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selected?.id == id) {
      _selected = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selected = address;
    notifyListeners();
  }

  void setDefault(String id) {
    for (int i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    notifyListeners();
  }
}