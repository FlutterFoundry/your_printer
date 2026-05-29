enum ConnectionType { lan, usb, bluetooth }

class Printer {
  final String id;
  final String name;
  final ConnectionType connectionType;
  final String? ipAddress;
  final int? port;
  final String? macAddress;
  final String? usbIdentifier;

  const Printer({
    required this.id,
    required this.name,
    required this.connectionType,
    this.ipAddress,
    this.port,
    this.macAddress,
    this.usbIdentifier,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connectionType': connectionType.index,
        'ipAddress': ipAddress,
        'port': port,
        'macAddress': macAddress,
        'usbIdentifier': usbIdentifier,
      };

  factory Printer.fromJson(Map<String, dynamic> json) => Printer(
        id: json['id'] as String,
        name: json['name'] as String,
        connectionType:
            ConnectionType.values[json['connectionType'] as int],
        ipAddress: json['ipAddress'] as String?,
        port: json['port'] as int?,
        macAddress: json['macAddress'] as String?,
        usbIdentifier: json['usbIdentifier'] as String?,
      );

  Printer copyWith({
    String? id,
    String? name,
    ConnectionType? connectionType,
    String? ipAddress,
    int? port,
    String? macAddress,
    String? usbIdentifier,
  }) =>
      Printer(
        id: id ?? this.id,
        name: name ?? this.name,
        connectionType: connectionType ?? this.connectionType,
        ipAddress: ipAddress ?? this.ipAddress,
        port: port ?? this.port,
        macAddress: macAddress ?? this.macAddress,
        usbIdentifier: usbIdentifier ?? this.usbIdentifier,
      );

  String get connectionLabel {
    switch (connectionType) {
      case ConnectionType.lan:
        return 'LAN';
      case ConnectionType.usb:
        return 'USB';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
    }
  }
}
