// หัวจ่ายไฟ EV เก็บใน collection `chargers`
class Charger {
  const Charger({
    this.docId,
    required this.chargerId,
    required this.location,
    required this.engineerEmail,
    required this.powerKw,
    required this.price,
  });

  final String? docId;
  final String chargerId;
  final String location;
  final String engineerEmail;
  final double powerKw;
  final double price; // ราคา (บาท)

  static String fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  String get powerLabel => fmt(powerKw);
  String get priceLabel => fmt(price);

  factory Charger.fromMap(String docId, Map<String, dynamic> m) {
    return Charger(
      docId: docId,
      chargerId: (m['chargerId'] ?? '') as String,
      location: (m['location'] ?? '') as String,
      engineerEmail: (m['engineerEmail'] ?? '') as String,
      powerKw: (m['powerKw'] as num?)?.toDouble() ?? 0,
      // รองรับเอกสารเก่าที่เคยเก็บเป็น income / tariff
      price: ((m['price'] ?? m['income'] ?? m['tariff']) as num?)?.toDouble() ??
          0,
    );
  }

  Map<String, dynamic> toMap() => {
        'chargerId': chargerId,
        'location': location,
        'engineerEmail': engineerEmail,
        'powerKw': powerKw,
        'price': price,
      };
}
