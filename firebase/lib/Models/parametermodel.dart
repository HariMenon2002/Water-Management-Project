class Parameters {
  double? ph;
  double? hardness;
  double? solids;
  double? chloramines;
  double? conductivity;
  double? turbidity;

  Parameters(
      {this.ph,
        this.hardness,
        this.solids,
        this.chloramines,
        this.conductivity,
        this.turbidity});

  Parameters.fromJson(Map<String, dynamic> json) {
    ph = json['ph'];
    hardness = json['Hardness'];
    solids = json['Solids'];
    chloramines = json['Chloramines'];
    conductivity = json['Conductivity'];
    turbidity = json['Turbidity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ph'] = this.ph;
    data['Hardness'] = this.hardness;
    data['Solids'] = this.solids;
    data['Chloramines'] = this.chloramines;
    data['Conductivity'] = this.conductivity;
    data['Turbidity'] = this.turbidity;
    return data;
  }
}