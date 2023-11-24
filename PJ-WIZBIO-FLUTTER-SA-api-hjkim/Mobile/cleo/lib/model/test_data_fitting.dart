// ignore_for_file: constant_identifier_names

enum CalcMode { NONE, SUBSTRACT, SUBSTRACT_CURVE_FIT }

class FittingDataCalculator {
  static const MAX_CYCLE = 50;
  static const BASELINE_START_POINT = 5;
  static const DISSOLUTION_TIME = 30;
  // static const NONE = 0;
  // static const SUBSTRACT = 1;
  // static const SUBSTRACT_CURVE_FIT = 2;
  // static const CT_VALUE = 50.0;
  late final CT_VALUE;

  FittingDataCalculator({double? ctValue}) : CT_VALUE = ctValue ?? 50;

  int _findBaseEndPoint(List<double> sData, int ePos) {
    double max = 0;
    int maxIdx = 0;
    int i;

    for (i = 5; i < ePos; i++) {
      if (sData[i] > max) {
        max = sData[i];
        maxIdx = i;
      }
    }

    return maxIdx;
  }

  List<double> _rawToVarConversion(
      List<double> sData, List<double> dData, int ePos) {
    int i;

    for (i = 1; i < ePos; i++) {
      dData[i] = sData[i] - sData[i - 1];
    }
    dData[0] = dData[1];
    return dData;
  }

  List<double> _baseSubstract(List<double> sData, List<double> dData,
      int baseStartPos, int baseEndPos, int maxCycle) {
    int i;
    double slope, perSlope;
    double baseThreshold;
    slope = sData[baseEndPos] - sData[baseStartPos];
    perSlope = slope / ((baseEndPos - baseStartPos) + 1);

    //slope process
    for (i = 0; i < maxCycle; i++) {
      if (slope > 0) {
        dData[i] = sData[i] - ((i + 1) * perSlope).abs();
      } else {
        dData[i] = sData[i] + ((i + 1) * perSlope).abs();
      }
    }

    baseThreshold = 0;

    for (i = baseStartPos; i <= baseEndPos; i++) {
      baseThreshold += dData[i];
    }

    baseThreshold /= ((baseEndPos - baseStartPos) + 1);

    for (i = 0; i < maxCycle; i++) {
      if (baseThreshold > 0) {
        dData[i] = dData[i] - baseThreshold.abs();
      } else {
        dData[i] = dData[i] + baseThreshold.abs();
      }
    }
    return dData;
  }

  List<double> _avrfilter(List<double> sData, List<double> dData, int ePos) {
    int i;

    for (i = 0; i < ePos; i++) {
      if (i == 0) {
        dData[i] = (sData[i] + sData[i + 1]) / 2;
      } else if (i == (ePos - 1)) {
        dData[i] = (sData[i - 1] + sData[i]) / 2;
      } else {
        dData[i] = (sData[i - 1] + sData[i] + sData[i + 1]) / 3;
      }
    }
    return dData;
  }

  double _findCT(List<double> sData, int baseEndPos, int ePos, double ct) {
    double delta = 0;
    double pDelta = 0;
    double mCT_idx = 0;
    double sCT_idx = 0;

    for (int i = baseEndPos; i < ePos - 1; i++) {
      if (sData[i] > ct) {
        delta = sData[i] - sData[i - 1];
        pDelta = double.parse((delta / 100).toStringAsFixed(3));
        mCT_idx = i.toDouble();
        for (int j = 0; j < 100; j++) {
          if ((sData[i - 1] + (j * pDelta)) > ct) {
            sCT_idx = j.toDouble();
            break;
          }
        }
        break;
      }
    }

    mCT_idx = mCT_idx + (sCT_idx / 100);

    return double.parse(mCT_idx.toStringAsFixed(3));
  }

  Future<List<List<double>>> pcrDataProcess(
      List<List<int>> sData, List<List<double>> dData, CalcMode mode) async {
    // fitting data process
    List<double> sourceY = List.generate(MAX_CYCLE, (i) => 0.0);
    List<double> rawDataFilter = List.generate(MAX_CYCLE, (i) => 0.0);
    List<double> varData = List.generate(MAX_CYCLE, (i) => 0.0);
    List<double> varDataFilter = List.generate(MAX_CYCLE, (i) => 0.0);
    List<double> baselineSubstract = List.generate(MAX_CYCLE, (i) => 0.0);

    double min, max;
    int maxIdx = -1, minIdx;

    int i, ch;

    for (ch = 0; ch < 3; ch++) {
      for (i = 0; i < MAX_CYCLE; i++) {
        sourceY[i] = sData[ch][i + DISSOLUTION_TIME].toDouble();
      }

      // Baseline none
      if (mode == CalcMode.NONE) {
        for (i = 0; i < MAX_CYCLE; i++) {
          dData[ch][i] = sourceY[i].toDouble();
        }
        continue;
      }

      rawDataFilter = _avrfilter(sourceY, rawDataFilter, MAX_CYCLE);

      //Convert raw data to variation data
      varData = _rawToVarConversion(rawDataFilter, varData, MAX_CYCLE);

      // 2nd filter
      varDataFilter = _avrfilter(varData, varDataFilter, MAX_CYCLE);

      //find base line end point
      int endPointIdx = 0;
      endPointIdx = _findBaseEndPoint(varDataFilter, MAX_CYCLE);

      //Error Condition
      if (endPointIdx < 15) {
        maxIdx = 15;
      }

      int baseLineEndPoint = endPointIdx - 8; //minIdx;
      if (maxIdx == 15) {
        baseLineEndPoint = maxIdx - 8; //minIdx;
      }
      //Base line slope processing
      baselineSubstract = _baseSubstract(rawDataFilter, baselineSubstract,
          BASELINE_START_POINT, baseLineEndPoint, MAX_CYCLE);
      for (i = 0; i < MAX_CYCLE; i++) {
        dData[ch]
            .add(num.parse(baselineSubstract[i].toStringAsFixed(2)).toDouble());
      }
      dData[3].add(_findCT(baselineSubstract, baseLineEndPoint, MAX_CYCLE,
          CT_VALUE)); //CT_VALUE 각 시약마다 다르므로 앱에서 전송해줘야함. Covid-19 -> CTValue = 50;
    }
    return dData; // fitting data result value
  }
}
