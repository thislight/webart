class Config {
  Map<String, dynamic> rawMap;

  Config(this.rawMap);

  dynamic operator [](String key) => rawMap[key];
  operator []=(String key, var value) => rawMap[key] = value;
}
