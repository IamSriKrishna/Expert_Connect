class VendorSlotTiming {
  final int id;
  final String date;
  const VendorSlotTiming({required this.date, required this.id});

  factory VendorSlotTiming.fromJson(Map<String, dynamic> json) {
    return VendorSlotTiming(date: json['date'], id: json['vendor_id']);
  }

  Map<String, dynamic> toJson() {
    return {"vendor_id": id, "date": date};
  }
}
