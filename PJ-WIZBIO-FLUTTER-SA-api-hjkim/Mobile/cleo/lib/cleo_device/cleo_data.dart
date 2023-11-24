class CleoData {
  final String type;
  final int cycle;
  final int ch1;
  final int ch2;
  final int ch3;
  final double celcius;

  factory CleoData.fromMsg(str) {
    // final reg = RegExp(r'^S,([CP]),(\d+),(\d+),(\d+),(\d+),([0-9\.]+)$');
    final reg =
        RegExp(r'^S,([CP]),(\d+),(\d+),(\d+),(\d+),([0-9\.]+),[\w+]{4}$');
    final result = reg.firstMatch(str);
    if (result == null) {
      throw 'invalid CleoData message => $str';
    }
    final String type = result.group(1)!;
    final int cycle = int.parse(result.group(2)!);
    final int ch1 = int.parse(result.group(3)!);
    final int ch2 = int.parse(result.group(4)!);
    final int ch3 = int.parse(result.group(5)!);
    final double celcius = double.parse(result.group(6)!);

    return CleoData(type, cycle, ch1, ch2, ch3, celcius);
  }

  CleoData(this.type, this.cycle, this.ch1, this.ch2, this.ch3, this.celcius);

  @override
  String toString() {
    return 'S,$type,$cycle,$ch1,$ch2,$ch3,$celcius';
  }

  List<double> toList() {
    return [ch1.toDouble(), ch2.toDouble(), ch3.toDouble()];
  }
}
