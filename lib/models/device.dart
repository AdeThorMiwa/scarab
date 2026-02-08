class DeviceApplication {
  const DeviceApplication({required this.name, required this.packageId});

  final String name;
  final String packageId;

  Map<String, String> toMap() {
    return {'name': name, 'packageId': packageId};
  }
}
