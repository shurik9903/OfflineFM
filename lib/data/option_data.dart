class OptionData {
  OptionData({this.saveDays, this.pathToSave});

  String? saveDays;
  String? pathToSave;

  factory OptionData.fromJson(Map<String, dynamic> json) {
    return OptionData(
        saveDays: json['saveDays'], pathToSave: json['pathToSave']);
  }

  Map<String, dynamic> toJson() => {
        'saveDays': saveDays,
        'pathToSave': pathToSave,
      };
}
