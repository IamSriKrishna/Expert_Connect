class VendorAvailabeSlot {
  final bool sucess;
  final List<String> availableSlots;
  const VendorAvailabeSlot({
    required this.sucess,
    required this.availableSlots,
  });

  factory VendorAvailabeSlot.fromJson(Map<String, dynamic> json) {
    return VendorAvailabeSlot(
      sucess: json['success'],
      availableSlots: List.from(json['available_slots']),
    );
  }

  factory VendorAvailabeSlot.initial() {
    return VendorAvailabeSlot(sucess: false, availableSlots: []);
  }
}
