import 'dart:math';
import 'package:cleo/util/bubble.dart';
import 'package:cleo/cleo_device/cleo_device.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // 2023.10.12_CJH

// class SLOPES_INFO {
//   late List<double> peakValue;
//   late List<double> slope;
//   late List<int> peakIdx;
//   late List<int> slopeStartIdx;
//   late List<int> rSlopeCnt;
//   late List<int> fSlopeCnt;
//   late int peakCnt;

//   // late int final_PeakIdx;
//   // late int final_StartIdx;
//   late int newBaseEndPoint;
// }

class FittingDataCalc{
  // 2023.04.25_OSJ
  static const AVERAGE_VALUE_CYCLE = 3;
  static const MAX_CYCLE = CleoDevice.TEST_CYCLE; // 2023.10.12_CJH
  // 2023.04.25_OSJ
  static const PRE_CYCLE_INDEX = CleoDevice.SP_TEST_CYCLE; // 2023.10.12_CJH
  static const PRE_CYCLE_TIME = CleoDevice.SP_TEST_TIME; // 2023.10.12_CJH
  static const MEASURE_CYCLE_INDEX = MAX_CYCLE; // 2023.09.11_CJH
  static const MEASURE_CYCLE_TIME = CleoDevice.TEST_TIME; // 2023.10.12_CJH
  static const TOTAL_CYCLE_INDEX = PRE_CYCLE_INDEX + MEASURE_CYCLE_INDEX; // 2023.10.12_CJH
  //static const BASELINE_START_POINT = 5;
  // static const BASELINE_START_POINT = 2;
  static const DISSOLUTION_TIME = CleoDevice.SP_TEST_CYCLE; // 2023.10.12_CJH
  static const M_START_INDEX = 5; // 2023.10.12_CJH

  // static const NONE = 0;
  // static const SUBSTRACT = 1;
  // static const SUBSTRACT_CURVE_FIT = 2;
  // static const POINT_DISTANCE = 10;
  // late List<double> sigmoidPos;
  double globalSum = 0;
  double globalM = 0;
  double globalB = 0;
  int globalPos = 0;
  int startPointIndex = 0;
  int dmPeakIndex = 0;
  int endPointIndex = 0;
  double startPointValue = 0;
  double dmPeakValue = 0;
  double endPointValue = 0;
  double endPointDmValue = 0;
  List<double> averageValueList = List.generate(AVERAGE_VALUE_CYCLE, (i) => 0); // 2023.10.12_CJH
// 2023.08.21_CJH
  double startPointValue1 = 0;
  double endPointValue1 = 0;
  double startPointValue2 = 0;
  double endPointValue2 = 0;
  double startPointValue3 = 0;
  double endPointValue3 = 0;

  // Future<double> _avgRFU(List<double> sData, int idx, int maxIdx) async {
  //   double value;
  //   double divider;
  //   int sIdx, eIdx;

  //   value = 0;
  //   divider = 0;
  //   sIdx = idx - 1;
  //   eIdx = idx + 2;

  //   if (idx == 0) {
  //     sIdx = 0;
  //     eIdx = idx + 1;
  //   }

  //   if (eIdx >= maxIdx) {
  //     sIdx = maxIdx - 1;
  //     eIdx = maxIdx;
  //   }

  //   for (int i = sIdx; i < eIdx; i++) {
  //     value += sData[i];
  //     divider++;
  //   }

  //   value /= divider;

  //   return value;
  // }

  // Future<bool> _checkValidSignal(List<double> sData, List<double> posValue,
  //     int bStart, int bEnd, int dt, int maxCycle) async {
  //   double sValue = 0;
  //   double eValue = 0;

  //   if (bEnd == 0) return false;

  //   sValue = await _avgRFU(sData, bStart, maxCycle);
  //   //eValue = await _avgRFU(sData, bEnd, maxCycle);
  //   double max = 0;
  //   double avgValue;
  //   for (int i = bStart + 1; i < maxCycle - 1; i++) {
  //     avgValue = (sData[i - 1] + sData[i] + sData[i + 1]) / 3;
  //     if (avgValue > max) max = avgValue;
  //   }
  //   eValue = max;

  //   if ((eValue < sValue) || (eValue - sValue) < 400) return false;

  //   sigmoidPos[0] = sValue;
  //   sigmoidPos[1] = eValue;

  //   //option
  //   //if ((bEnd - bStart) < 5) return false;

  //   return true;
  // }

  // Future<int> _findBaseEndPoint(
  //     List<double> sData, SLOPES_INFO slopes, int maxCycle) async {
  //   int i;
  //   int baslineStartPoint = 5;

  //   List<double> dData = List.generate(MAX_CYCLE, (i) => 0.0);
  //   List<double> dData_2nd = List.generate(MAX_CYCLE, (i) => 0.0);
  //   double slope, preSlope, perSlope;
  //   int rSlopeCnt, fSlopeCnt;

  //   slope = 0;
  //   rSlopeCnt = 0;
  //   fSlopeCnt = 0;
  //   preSlope = sData[0];

  //   slopes.peakCnt = 0;

  //   for (i = 1; i < maxCycle; i++) {
  //     slope = sData[i];

  //     if (slope < preSlope) {
  //       if (rSlopeCnt != 0) {
  //         slopes.peakCnt++;
  //       }

  //       rSlopeCnt = 0;
  //       fSlopeCnt++;

  //       if (slopes.peakCnt != 0) {
  //         slopes.fSlopeCnt[slopes.peakCnt - 1] = fSlopeCnt;
  //       }
  //     } else {
  //       fSlopeCnt = 0;
  //       rSlopeCnt++;

  //       slopes.rSlopeCnt[slopes.peakCnt] = rSlopeCnt;
  //       slopes.peakValue[slopes.peakCnt] = sData[i];
  //       slopes.peakIdx[slopes.peakCnt] = i;
  //       if (rSlopeCnt == 1) slopes.slopeStartIdx[slopes.peakCnt] = i;
  //     }

  //     preSlope = slope;
  //   }

  //   double max = 0;

  //   for (i = 0; i < slopes.peakCnt; i++) {
  //     slopes.slope[i] =
  //         (sData[slopes.peakIdx[i]] - sData[slopes.slopeStartIdx[i]]) /
  //             (slopes.peakIdx[i] - slopes.slopeStartIdx[i] + 1);
  //   }

  //   slopes.final_StartIdx = 0;
  //   slopes.final_PeakIdx = 0;

  //   double maxValue = 0;
  //   int idx = 0xFF;
  //   for (i = 0; i < slopes.peakCnt; i++) {
  //     if (slopes.rSlopeCnt[i] < 5) continue;
  //     if (slopes.peakValue[i] < 40) continue;

  //     if (slopes.slope[i] > maxValue) {
  //       maxValue = slopes.slope[i];
  //       //baslineStartPoint = slopes.slopeStartIdx[i];
  //       idx = i;
  //     }
  //   }

  //   if (idx == 0xFF) {
  //     baslineStartPoint = maxCycle - 1;
  //     return baslineStartPoint;
  //   }

  //   List<double> aData = List.generate(MAX_CYCLE, (x) => 0.0);
  //   int aDataIdx = 0;

  //   double peakSquareValue =
  //       (sData[slopes.peakIdx[idx]] * sData[slopes.peakIdx[idx]]) * 0.01;

  //   for (i = slopes.slopeStartIdx[idx]; i <= slopes.peakIdx[idx]; i++) {
  //     aData[aDataIdx++] = (sData[i] * sData[i]) - peakSquareValue;
  //   }

  //   for (i = 0; i < aDataIdx; i++) {
  //     if (aData[i] > 0) {
  //       baslineStartPoint = (i + slopes.slopeStartIdx[idx]) - 1;
  //       break;
  //     }
  //   }

  //   slopes.final_StartIdx = baslineStartPoint;
  //   slopes.final_PeakIdx = slopes.peakIdx[idx];

  //   return baslineStartPoint;

  //   // double max = 0;
  //   // int maxIdx = 0;
  //   // int i;

  //   // for (i = 5; i < ePos; i++) {
  //   //   if (sData[i] > max) {
  //   //     max = sData[i];
  //   //     maxIdx = i;
  //   //   }
  //   // }

  //   // return maxIdx;
  // }

  Future<List<double>> _slope(
      List<double> sData, List<double> dData, int ePos, int start) async { // 2023.10.12_CJH
    for (int i = start + 1; i < ePos; i++) { // 2023.10.12_CJH
      dData[i] = sData[i] - sData[i - 1];
    }
    // dData[0] = dData[1];
    return dData;
  }

  // Future<List<double>> _baseSubstract(List<double> sData, List<double> dData,
  //     int baseStartPos, int baseEndPos, int maxCycle) async {
  //   int i;
  //   double slope, perSlope;
  //   double baseThreshold;
  //   slope = sData[baseEndPos] - sData[baseStartPos];
  //   perSlope = slope / ((baseEndPos - baseStartPos) + 1);

  //   //slope process
  //   for (i = 0; i < maxCycle; i++) {
  //     if (slope > 0) {
  //       dData[i] = sData[i] - ((i + 1) * perSlope).abs();
  //     } else {
  //       dData[i] = sData[i] + ((i + 1) * perSlope).abs();
  //     }
  //   }

  //   baseThreshold = 0;

  //   for (i = baseStartPos; i <= baseEndPos; i++) {
  //     baseThreshold += dData[i];
  //   }

  //   baseThreshold /= ((baseEndPos - baseStartPos) + 1);

  //   for (i = 0; i < maxCycle; i++) {
  //     if (baseThreshold > 0) {
  //       dData[i] = dData[i] - baseThreshold.abs();
  //     } else {
  //       dData[i] = dData[i] + baseThreshold.abs();
  //     }
  //   }
  //   return dData;
  // }

  // Future<List<double>> _avrfilter(
  //     List<double> sData, List<double> dData, int ePos) async {
  //   int i;

  //   for (i = 0; i < ePos; i++) {
  //     if (i == 0) {
  //       dData[i] = (sData[i] + sData[i + 1]) / 2;
  //     } else if (i == (ePos - 1)) {
  //       dData[i] = (sData[i - 1] + sData[i]) / 2;
  //     } else {
  //       dData[i] = (sData[i - 1] + sData[i] + sData[i + 1]) / 3;
  //     }
  //   }
  //   return dData;
  // }

  Future<double> _getCtValue(
      List<double> fitArr, List<double> index, int n, int cutoff) async {
    double ct = 0;
    double ctValue = 0;
    double ctPreValue = 0;
    double ctIndex = 0;
        if (endPointIndex != TOTAL_CYCLE_INDEX - 1) {  // 2023.10.12_CJH
      // if (endPointIndex != int.parse(crntCartridge!.afterTestCycle) + int.parse(crntCartridge!.afterTestCycle) - 1) {  // 2023.10.12_CJH
      // 2023.03.24_osj
      for (int i = (startPointIndex + 1); i < n; i++) {
        if (fitArr[i] > fitArr[i - 1]) {
          if (fitArr[i] > cutoff.toDouble()) {
            ct = index[i];
            ctPreValue = fitArr[i - 1];
            ctValue = fitArr[i];
            ctIndex = (cutoff - ctValue) * 1 /
            ((ctValue - ctPreValue) / (index[i] - index[i - 1])) + ct;
            break;
          }
        }
      }
    }
    return ctIndex; // 2023.10.12_CJH
  }

  // Future<double> _findCT(
  //     List<double> sData, int baseEndPos, int ePos, double ct) async {
  //   int i, j;
  //   double delta = 0;
  //   double pDelta = 0;
  //   double mCT_idx = 0;
  //   double sCT_idx = 0;
  //   int fCTIdx = 0;

  //   for (i = baseEndPos; i < ePos - 1; i++) {
  //     if (sData[i] > ct) {
  //       fCTIdx = i;
  //       break;
  //     }
  //   }

  //   if (fCTIdx != 0) {
  //     for (i = fCTIdx; i < ePos - 1; i++) {
  //       if (sData[i] < ct) {
  //         fCTIdx = 0;
  //       }
  //     }
  //   }

  //   mCT_idx = 0;

  //   if (fCTIdx != 0) {
  //     for (i = baseEndPos; i < ePos - 1; i++) {
  //       if (sData[i] > ct) {
  //         delta = sData[i] - sData[i - 1];
  //         pDelta = double.parse((delta / 100).toStringAsFixed(3));
  //         mCT_idx = i.toDouble();
  //         for (j = 0; j < 100; j++) {
  //           if ((sData[i - 1] + (j * pDelta)) > ct) {
  //             sCT_idx = j.toDouble();
  //             break;
  //           }
  //         }
  //         break;
  //       }
  //     }
  //     mCT_idx = mCT_idx + (sCT_idx / 100);
  //   }

  //   return double.parse((mCT_idx).toStringAsFixed(3));
  // }

  Future<List<double>> _copyData(
      List<List<double>> sData, List<double> dData, int ch, int ePos) async { // 2023.10.12_CJH
    int i;

    for (i = 0; i < ePos; i++) {
      //dData[i] = sData[ch][i + DISSOLUTION_TIME].toDouble();
      dData[i] = sData[ch][i].toDouble();
    }
    return dData;
  }

  Future<List<double>> _indexCopyData(List<double> sData, int n, double start,
      double add_measure, int pre_n, double add_pre) async {
    double j = start + add_pre; // 2023.10.12_CJH
    double result = 0;  // 2023.09.11_CJH
    // 2023.04.25_OSJ
     // 2023.10.12_CJH
    for (int i = 0; i < n; i++) {
      if (i < pre_n - 1) {
        // if ((i - 2) % 3 == 0 && i >= 2) {
          result = (j * 10);
          sData[i] = result.round().toDouble() / 10;
          result = 0; // 2023.09.11_CJH
          // sData[i] = j;
        // } else {
        //   sData[i] = j;
        // }

        j = j + add_pre;
      } else {
        result = (j * 10);
        sData[i] = result.round().toDouble() / 10;
        result = 0; // 2023.09.11_CJH
        j = j + add_measure;
      }
    }
    return sData;
  }

  Future<List<double>> _fitMovingAverage(
      List<double> sData,
      int ePos,
      List<double> averageValueList, // 2023.10.12_CJH
      int averageValueListCycle,
      List<double> dData,
      int start) async { // 2023.10.12_CJH
    double movingAverage = 0;

    for (int i = start; i < ePos; i++) { // 2023.10.12_CJH
      movingAverage = await _movingAvg(
          averageValueList, averageValueListCycle, sData[i]); // 2023.10.12_CJH
      if (i >= averageValueListCycle) {
        dData[i] = movingAverage;
      }
    }
    return dData;
  }

  Future<double> _movingAvg(
      List<double> averageValueList, int n, double nextNum) async { // 2023.10.12_CJH
    globalSum = globalSum - (averageValueList[globalPos]).toDouble() + nextNum;

    averageValueList[globalPos] = nextNum;

    globalPos++;
    if (globalPos >= n) {
      globalPos = 0;
    }

    return (globalSum / n);
  }

  Future<List<double>> _pdLeastSquare(
      List<double> iData,
      List<double> sData, // 0 ~ 49
      int maxCycle,
      List<double> dData,
      // 2023.04.25_OSJ
      int start_n) async {
    // 2023.04.25_OSJ
    for (int i = start_n + 1; i < maxCycle; i++) {
      // globalM = await _leastSquare(iData, sData, i + 1);
      // 2023.04.25_OSJ
      globalM = await _leastSquare(iData, sData, start_n, i + 1);
      dData[i] = globalM; // 0 ~ 49
    }
    return dData;
  }

  Future<double> _leastSquare(
      List<double> sData, List<double> dData, int start, int maxCycle) async {
    double xBar = await _mean(sData, start, maxCycle);
    double yBar = await _mean(dData, start, maxCycle);
    double sum1 = 0, sum2 = 0;

    // Calculate sum1 , sum2
    // 2023.04.25_OSJ
    for (int i = start; i < maxCycle; i++) {
      // 2023.04.25_OSJ
      sum1 += (sData[i] - xBar) * (dData[i] - yBar);
      sum2 += pow((sData[i] - xBar), 2);
    }
    globalM = sum1 / sum2;
    globalB = yBar - globalM * xBar;
    return globalM;
  }

  Future<double> _mean(List<double> sData, int start, int maxCycle) async {
    double sum = 0, mean = 0;

    // sum of arr
    // for (int i = 0; i < maxCycle; i++) {
    //   sum += sData[start + i];
    // }

    // mean = sum / maxCycle;
    for (int i = start; i < maxCycle; i++) {
      sum += sData[i];
    }

    mean = sum / (maxCycle - start);

    return mean;
  }

  Future<double> _baseLineEndPoint(
      List<double> sData, // 2023.09.07_cjh
      List<double> dArr,
      List<double> mArr,
      List<double> dmArr,
      int dmArrIndex,
      List<double> index,
      double min,
      double preMin,  // 2023.09.07_cjh
      int dmValue,
      int bubbleValue,
      double dmRange,
      List<double> dmReferenceArray,
      List<double> movingAverageValue) async {
    double minValue = 100000;
    double compareValue = 0;
    // 2023.04.25_OSJ
    double dmReferenceValue = 0;
    double dmReferenceRatio = 0.95;
    dmPeakIndex = 0;
    dmPeakValue = 0;
    endPointIndex = 0;
    endPointValue = index[0];
    endPointDmValue = 100000;
    int minIndex = 0; // 2023.10.10_CJH

    // 2023.09.07_cjh
    // array_reverse

    List<double> sDataBack = List.generate(dmArrIndex, (i) => 0);
    List<double> dmArrIndexBack = List.generate(dmArrIndex, (i) => 0);
    List<double> pdLeastSquareValueBack = List.generate(dmArrIndex, (i) => 0.0);
    List<double> fitMSlopeValueBack = List.generate(dmArrIndex, (i) => 0.0);
    List<double> arrayReverse = List.generate(dmArrIndex, (i) => 0.0);

    for (int y = 0; y < dmArrIndex; y++) {
      sDataBack[y] = sData[dmArrIndex - (y + 1)];
      dmArrIndexBack[y] = index[dmArrIndex - (y + 1)];
    }

    pdLeastSquareValueBack = await _pdLeastSquare(
        dmArrIndexBack, sDataBack, dmArrIndex, pdLeastSquareValueBack, M_START_INDEX); // 2023.10.12_CJH

    fitMSlopeValueBack =
        await _slope(pdLeastSquareValueBack, fitMSlopeValueBack, dmArrIndex, M_START_INDEX + 1); // 2023.10.12_CJH

    for (int y = 0; y < dmArrIndex; y++) {
      arrayReverse[y] = fitMSlopeValueBack[dmArrIndex - (y + 1)];
    }
    for (int y = 0; y < dmArrIndex; y++) {
      fitMSlopeValueBack[y] = arrayReverse[y];
    }

//end point�� �ִ밪 ã��
//	for (int a = 0; a <= n+1; a++)
    for (int a = 0; a < dmArrIndex; a++) {
      if (index[a] > min) { // 2023.10.12_CJH
        for (int i = a - 1; i < dmArrIndex; i++) //min������ dm�� peak�� ã�� // 2023.10.12_CJH
        {
          dmReferenceArray[i] = dmReferenceValue;

          // 2023.04.25_OSJ
          // 2023.09.07_cjh
          if (index[i] <= preMin &&
              (fitMSlopeValueBack[i - 2] + 
              fitMSlopeValueBack[i - 1] + 
              fitMSlopeValueBack[i]) / 3 > 
              dmReferenceArray[i]) //fitMSlopeValueBack = i-1
          {
            if (movingAverageValue[i] > movingAverageValue[dmPeakIndex]) {
              if (movingAverageValue[i] > dmValue) {
                if (fitMSlopeValueBack[i - 1] > fitMSlopeValueBack[i - 2] &&
                    fitMSlopeValueBack[i - 1] > fitMSlopeValueBack[i - 3]) {
                  if (movingAverageValue[i] >= 1) {
                    if (fitMSlopeValueBack[i - 1] > 0.3) {
                      dmPeakValue = dmArr[i];
                      dmPeakIndex = i;
                    }
                  }
                }
              }
            }
          } else if (i < dmArrIndex - 1 &&
              // 2023.09.01_CJH
              (dmArr[i - 1] + dmArr[i] + dmArr[i + 1]) / 3 > 
              dmReferenceArray[i]) {
            // 2023.03.24_OSJ
            // 2023.08.21_CJH
            if (movingAverageValue[i] > movingAverageValue[dmPeakIndex]) {
              if (movingAverageValue[i] > dmValue) {
                // 2023.04.25_OSJ
                if (dmArr[i] > dmArr[i - 1] && dmArr[i] > dmArr[i - 2]) {
                  minValue = 100000;
                  compareValue = 0;

                  for (int b = i - 3;
                  b >= i - 5;
                  b--) //i�� 3,4,5�� �����Ϳ��� �ּҰ� ã��
                  {
                    if (dmArr[b] < minValue) {
                      minValue = dmArr[b];
                    }
                  }
                  compareValue = minValue + (dmArr[i] - minValue) * 0.8;
                  // 2023.04.25_OSJ
                  if (movingAverageValue[i] >= 1) {
                    dmPeakValue = dmArr[i];
                    dmPeakIndex = i;
                  }
                }
              }
            }
            // 2023.04.25_OSJ
          } else if (i == dmArrIndex - 1 &&
              // 2023.09.01_CJH
              (dmArr[i - 2] + dmArr[i - 1] + dmArr[i]) / 3 >
                  dmReferenceArray[i]) {
            // 2023.03.24_osj // 2023.04.25_OSJ
            // 2023.09.11_CJH
            if (movingAverageValue[i] > movingAverageValue[dmPeakIndex]) {
              // 2023.04.25_OSJ
              if (movingAverageValue[i] > dmValue * 0.2) {
                if (dmArr[i] > dmArr[i - 1] &&
                    dmArr[i] > dmArr[i - 2]) //���� 2�� ������ �������� ��° �϶�
                {
                  if (movingAverageValue[i] >= 1) {
                    dmPeakValue = dmArr[i];
                    dmPeakIndex = i;
                  }
                }
              }
            }
          }
// 2023.08.21_CJH
//           if (i < dmArrIndex - 5) {
//             //if (dArr[i] > dArr[dmPeakIndex])
//             if (dmArr[i + 1] > dmArr[dmPeakIndex] &&
//                 movingAverageValue[i + 1] > 5 &&
//                 movingAverageValue[i + 1] >= 10) //peak compare
//             {
//               //if ((movingAverageValue[i + 1] >= movingAverageValue[i] && movingAverageValue[i] >= movingAverageValue[i + 1] * 0.5)
//               //|| (movingAverageValue[i + 2] >= movingAverageValue[i + 1] && movingAverageValue[i + 1] >= movingAverageValue[i + 2] * 0.5)
//               //|| (movingAverageValue[i] >= movingAverageValue[i - 1] && movingAverageValue[i - 1] >= movingAverageValue[i] * 0.5)) //mv before peak's find
//
//               if (movingAverageValue[i + 1] >= movingAverageValue[i] &&
//                   movingAverageValue[i] >=
//                       movingAverageValue[i + 1] * 0.5) //mv before peak's find
//               {
//                 if (movingAverageValue[i] >
//                     movingAverageValue[i - 2]) //mv before peak's find
//                 {
//                   if (movingAverageValue[i - 1] >
//                       movingAverageValue[i - 3]) //mv before peak's find
//                   {
//                     if (movingAverageValue[i - 2] >
//                         movingAverageValue[i - 4]) //mv before peak's find
//                     {
//                       if (movingAverageValue[i + 1] >=
//                               movingAverageValue[i + 2] &&
//                           movingAverageValue[i + 2] >
//                               movingAverageValue[i + 1] *
//                                   0.5) //mv after peak's find
//                       {
//                         if (movingAverageValue[i + 2] >
//                             movingAverageValue[i + 4]) //mv before peak's find
//                         {
//                           //if (movingAverageValue[i + 3] > movingAverageValue[i + 5]) //mv before peak's find
//                           //{
//
//                           //if (dArr[i] > dArr[dmPeakIndex] && dArr[i] > 5)    //peak compare
//                           //{
//                           if (dmArr[i] > dmPeakValue && dmPeakValue != 0) {
//                             if (dmArr[i] > 0) {
//                               //if ((dmArr[i   ] >= dmArr[i - 1] && dmArr[i  ] > dmArr[i - 2])
//                               //|| (dmArr[i + 1] >= dmArr[i   ] && dmArr[i + 1] > dmArr[i - 1]) //after
//                               //|| (dmArr[i + 2] >= dmArr[i + 1] && dmArr[i + 2] > dmArr[i  ])  //after
//
//                               //|| (dmArr[i - 1] >= dmArr[i - 2] && dmArr[i - 1] > dmArr[i - 3])
//                               //|| (dmArr[i - 2] >= dmArr[i - 3] && dmArr[i - 2] > dmArr[i - 4])
//                               //|| (dmArr[i - 3] >= dmArr[i - 4] && dmArr[i - 3] > dmArr[i - 5])
//                               //|| (dmArr[i - 4] >= dmArr[i - 5] && dmArr[i - 4] > dmArr[i - 6]))
//                               //{
//                               //    dmPeakValue = dmArr[i];  //peak change
//                               //    dmPeakIndex = i;
//                               //}
//                               if ((dmArr[i] >= dmArr[i - 2] &&
//                                       dmArr[i] > dmArr[i - 3]) ||
//                                   (dmArr[i + 1] >= dmArr[i - 1] &&
//                                       dmArr[i + 1] > dmArr[i - 2]) ||//after
//                                   (dmArr[i + 2] >= dmArr[i] &&
//                                       dmArr[i + 2] > dmArr[i - 1]) ||//after
//
//                                   (dmArr[i - 1] >= dmArr[i - 3] &&
//                                       dmArr[i - 1] > dmArr[i - 4]) ||
//                                   (dmArr[i - 2] >= dmArr[i - 4] &&
//                                       dmArr[i - 2] > dmArr[i - 5]) ||
//                                   (dmArr[i - 3] >= dmArr[i - 5] &&
//                                       dmArr[i - 3] > dmArr[i - 6]) ||
//                                   (dmArr[i - 4] >= dmArr[i - 6] &&
//                                       dmArr[i - 4] > dmArr[i - 7])) {
//                                 dmPeakValue = dmArr[i]; //peak change
//                                 dmPeakIndex = i;
//                               }
//                             }
//                           } else {
//                             if (movingAverageValue[i + 1] >=
//                                     movingAverageValue[i - 1] &&
//                                 movingAverageValue[i] >=
//                                     movingAverageValue[i - 2] &&
//                                 movingAverageValue[i - 1] >=
//                                     movingAverageValue[i - 3] &&
//                                 movingAverageValue[i - 2] >=
//                                     movingAverageValue[i - 4] &&
//                                 movingAverageValue[i - 3] >=
//                                     movingAverageValue[i - 5] &&
//                                 movingAverageValue[i + 1] >=
//                                     movingAverageValue[i + 3] &&
//                                 movingAverageValue[i + 2] >=
//                                     movingAverageValue[i + 4]) {
//                               dmPeakValue = dmArr[i]; //peak change
//                               dmPeakIndex = i;
//                             }
//                           }
//                           //}
//                           //}
//                         }
//                       }
//                     }
//                   }
//                 }
//               }
//             }
//           }
          // else
          // {
          //   if ((dmArr[i - 2] + dmArr[i - 1] + dmArr[i]) / 3 > dmReferenceArray[i])
          //   {
          //     //if (dArr[i] > dArr[dmPeakIndex])
          //     ////if (dArr[i] > dArr[dmPeakIndex] && (movingAverageValue[i] + movingAverageValue[i - 1] + movingAverageValue[i - 2]) > (movingAverageValue[dmPeakIndex] + movingAverageValue[dmPeakIndex - 1] + movingAverageValue[dmPeakIndex - 2]))
          //     if (movingAverageValue[i] > movingAverageValue[dmPeakIndex])
          //     {
          //       if (movingAverageValue[i] > dmValue * 0.2)
          //       {
          //         if (dmArr[i] > dmArr[i - 1] && dmArr[i] > dmArr[i - 2])
          //         {
          //           if (movingAverageValue[i] >= 1)
          //           {
          //             dmPeakValue = dmArr[i];
          //             dmPeakIndex = i;
          //           }
          //         }
          //       }
          //     }
          //   }
          // }
          // 2023.04.25_OSJ
          //dmReferenceValue = dmReferenceValue * dmReferenceRatio;
        }
        if (dmPeakIndex == 0) //peak�� ������ endpoint �ִ밪���� ���
        {
          endPointIndex = dmArrIndex - 1;
          endPointValue = index[dmArrIndex - 1];
          endPointDmValue = dmArr[dmArrIndex - 1];
        }
        if (dmPeakIndex < dmArrIndex && dmPeakIndex > 0) //0����Ŭ��
        {
          // 2023.04.25_OSJ
          // 2023.10.10_CJH
          for (int i = dmPeakIndex - 4;
              i >= dmPeakIndex - 40 && index[i] >= min - 1;
              i--) {
            if (dmArr[i] > dmArr[i - 1] &&
            endPointDmValue > dmArr[i - 1]) //������ ������Ʈ
            {
              endPointIndex = i - 1;
              endPointValue = index[i - 1];
              endPointDmValue = dmArr[i - 1];
            }
            if (dmPeakValue <= 0.15) {
              if (movingAverageValue[i] > movingAverageValue[i - 1]) {
                if (((movingAverageValue[i + 1] - movingAverageValue[i - 1]) / 2 < 0 ||
                    (movingAverageValue[i - 1] - movingAverageValue[i - 2]) / 2 < 0))
                //dm으로 endpoint를 잡기 힘들때 조건
                {
                  if (movingAverageValue[i - 1] <= movingAverageValue[i - 3] ||
                  movingAverageValue[i - 2] <= movingAverageValue[i - 4]) { 
                    minIndex = 0;
                    for (int b = i - 1;
                    b >= i - 10 && index[b] >= min - 1;
                    b--) {
                      if ((movingAverageValue[b] - movingAverageValue[i]).abs() > 2) {
                        minIndex++;
                      }
                    }
                    if (minIndex <= 3) {
                      endPointIndex = i - 1;
                      endPointValue = index[i - 1];
                      endPointDmValue = dmArr[i - 1];
                      break;
                    }
                  }
                }
              }
            } else {
              if (dmArr[i] <= (dmRange / 100) * dmPeakValue &&
                  (movingAverageValue[i] - movingAverageValue[i - 1]) / 2 <= 1 &&
                  movingAverageValue[i] <= movingAverageValue[dmPeakIndex] * 0.2) {
                endPointIndex = i;
                endPointValue = index[i];
                endPointDmValue = dmArr[i];
                break;
              } else {
                if ((dmArr[i - 1] < dmArr[i - 3] &&
                        dmArr[i - 2] < dmArr[i - 4]) &&
                    (dmArr[i] <= (dmRange / 100) * dmPeakValue)) {
                  endPointIndex = i;
                  endPointValue = index[i];
                  endPointDmValue = dmArr[i];
                  break;
                }
                if (movingAverageValue[i] < movingAverageValue[i - 1]) {
                  if (movingAverageValue[i] - movingAverageValue[i - 1] < 0) {
                    if (movingAverageValue[i] < 2) {
                      endPointIndex = i - 1;
                      endPointValue = index[i - 1];
                      endPointDmValue = dmArr[i - 1];
                      break;
                    }
                    if (((movingAverageValue[i - 1] <= movingAverageValue[i - 3] ||
                    movingAverageValue[i - 2] <= movingAverageValue[i - 4]) &&
                    dmArr[i] < 0) &&
                    movingAverageValue[dmPeakIndex] - movingAverageValue[endPointIndex] >= 8 &&
                    movingAverageValue[i] < movingAverageValue[endPointIndex]) {
                      minIndex = 0;
                      for (int b = i - 1;
                      b >= i - 10 && index[b] >= min - 1;
                      b--) {
                        if ((movingAverageValue[b] - movingAverageValue[i]).abs() > 2) {
                          minIndex++;
                        }
                      }
                      if (minIndex <= 3) {
                        endPointIndex = i - 1;
                        endPointValue = index[i - 1];
                        endPointDmValue = dmArr[i - 1];
                        break;
                      }
                    }
                  }
                }
              }
            }
            if (((dmArr[i - 1] < dmArr[i - 3]) ||
                    (dmArr[i - 2] < dmArr[i - 4])) &&
                index[i] <= min - 1) // min=7
            {
              endPointIndex = i;
              endPointValue = index[i];
              endPointDmValue = dmArr[i];
              break;
            }
          }
        }
        break;
      }
    }
    // 2023.10.10_CJH
    if (movingAverageValue[dmPeakIndex] - movingAverageValue[endPointIndex] < 8 && dmPeakIndex < dmArrIndex - 3) //작은 반응인경우 peak 초기화
    {
        endPointIndex = dmArrIndex - 1;
        endPointValue = index[dmArrIndex - 1];
        endPointDmValue = dmArr[dmArrIndex - 1];
    }
    // endPointValue = pdLeastSquareValue[endPointIndex];
    return endPointValue;
  }

//   Future<int> _maxArrIndex(sData, fitIndexData, int maxCycle) async {
//     int max = 0;
//     double maxValue = 0;
//     double maxIndex = 0;

//     for (int i = 0; i < maxCycle; i++) {
//       if (sData[i] > sData[max]) {
//         max = i;
//       }
//     }
//     maxIndex = fitIndexData[max];
//     maxValue = sData[max];

// //	uart_printf("max = %d, max_value = %lf, max_index = %lf\r", max, max_value, max_index);

//     return max;
//   }

// 2023.08.21_CJH
  Future<double> _baselineStartPoint(
      List<double> sData, // 2023.10.10_CJH
      List<double> dArr,
      List<double> movingAverageValue,
      List<double> dmArr,
      List<double> index,
      // List<double> fitIndexData,
      int bubbleValue,
      int start) async {
    // 2023.10.10_CJH
    double slopetick = 0;
    double pickMin = 0xFFFF;
    double pickMax = 0;
    int pickMinIndex = 0;
    int pickMaxIndex = 0;
    List<double> startPickArr = List.generate(TOTAL_CYCLE_INDEX, (i) => 0);

    // 2023.04.25_OSJ
    startPointIndex = start;
    // 2023.10.10_CJH
    startPointValue = index[startPointIndex];

    slopetick = (sData[endPointIndex] - sData[startPointIndex]) / 
    (endPointIndex - startPointIndex);    //구간별 기울기

    for (int i = startPointIndex; i <= endPointIndex; i++) {
        startPickArr[i] = sData[i] - ((i - startPointIndex) * slopetick);    //rawdata 영점
    }

    // 2023.10.10_CJH
    if (endPointIndex != TOTAL_CYCLE_INDEX - 1 && endPointIndex - 4 >= 1) {
      for (int i = startPointIndex; i < endPointIndex; i++){
        if(startPickArr[i] > pickMax) {
          pickMaxIndex = i;
          pickMax = startPickArr[i];

          pickMin = 0xFFFF;  //max보다 뒤에 min을 잡기위함
        }
        if (startPickArr[i] < pickMin) {
          pickMinIndex = i;
          pickMin = startPickArr[i];
        }

        if (pickMax - pickMin > 10) {
          if (pickMinIndex > pickMaxIndex) {
            startPointValue = index[pickMaxIndex] + 2; //2분 뒤를 startpoint로 설정
            for (int i = 0; i <= endPointIndex; i++) {
              if (index[i] >= startPointValue) {
                startPointIndex = i;
                startPointValue = index[startPointIndex];
                break;
              }
            }
          } else {
            startPointValue = index[pickMinIndex] + 2; //2분 뒤를 startpoint로 설정
            for (int i = 0; i <= endPointIndex; i++) {
              if (index[i] >= startPointValue) {
                startPointIndex = i;
                startPointValue = index[startPointIndex];
                break;
              }
            }
          }
          // if (endPointIndex - startPointIndex < 4) { //index로 판정
          //   startPointIndex = endPointIndex - 4;
          //   startPointValue = index[startPointIndex];
          // }
          if (endPointValue - startPointValue < 2) { //value로 판정
            startPointValue = index[endPointIndex] - 2; //2분 앞을 startpoint로 설정
            for (int i = 0; i <= endPointIndex; i++) {
              if (index[i] >= startPointValue) {
                if (i > start) {
                  startPointIndex = i;
                  startPointValue = index[startPointIndex];
                } else {
                  startPointIndex = start;
                  startPointValue = index[startPointIndex];
                }
                break;
              }
            }
          }
        }
        //after startpoint
        for (int i = startPointIndex + 1; i < endPointIndex - 4; i++) {
          if ((dArr[i] - dArr[i - 1]).abs() > 20) {//큰 변화일때만 적용
            startPointIndex = i;
            startPointValue = index[startPointIndex];
          }
        }
      }
    }
    else {
      startPointIndex = start;
      startPointValue = index[startPointIndex];
    }
    return startPointValue;
  }

  Future _baselineLeastSquare(
      List<double> fitIndexData,
      List<double> pdLeastSquareValue,
      int start,
      // 2023.04.25_OSJ
      int baselineLeastSquareValue) async {
    globalM = await _leastSquare(fitIndexData, pdLeastSquareValue, start,
        (start + baselineLeastSquareValue));
    return globalM;
  }

  // 2023.04.25_OSJ
  Future _baselineFitting(List<double> sData, List<double> dData,
      List<double> fitIndexData, int maxCycle, int start) async {
    for (int i = start; i < maxCycle; i++) {
      dData[i] = sData[i] - (globalM * fitIndexData[i] + globalB);
    }

    return dData;
  }

  Future<List<List<double>>> pcrDataProcess(List<List<int>> sData,
      List<List<double>> dData, int mode, String ctValue) async {

    // 2023.10.12_CJH
    List<List<double>> sDataDouble = sData.map((row) {
      return row.map((value) {
        return value.toDouble();
      }).toList();
    }).toList();

    // 2023.04.26_OSJ
    bubble b = bubble();
    sDataDouble = await b.bubbleDataProcess(sData, TOTAL_CYCLE_INDEX); // 2023.10.12_CJH
    // print(sData.toString());
    // fitting data process
    // List<double> fitIndexData = List.generate(MAX_CYCLE, (i) => 0.0);
    // List<double> sourceY = List.generate(MAX_CYCLE, (i) => 0.0);
    // List<double> slopeValue = List.generate(MAX_CYCLE, (i) => 0);
    // List<double> fitMSlopeValue = List.generate(MAX_CYCLE, (i) => 0);
    // List<double> movingAverageValue = List.generate(MAX_CYCLE, (i) => 0.0);
    // List<double> pdLeastSquareValue = List.generate(MAX_CYCLE, (i) => 0.0);
    // List<double> baselineFittingData = List.generate(MAX_CYCLE, (i) => 0.0);
    // List<double> dmReferenceArray = List.generate(MAX_CYCLE, (i) => 0.0);

    List<double> fitIndexData = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
    List<double> sourceY = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
    List<double> slopeValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0);
    List<double> fitMSlopeValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0);
    List<double> movingAverageValue =
        List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
    List<double> pdLeastSquareValue =
        List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
    List<double> baselineFittingData =
        List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
    List<double> dmReferenceArray =
        List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);

    // sigmoidPos = List.generate(2, (i) => 0.0);
    averageValueList = List.generate(5, (i) => 0);

    // 2023.08.21_CJH
    startPointValue1 = 0;
    startPointValue2 = 0;
    startPointValue3 = 0;

    endPointValue1 = 0;
    endPointValue2 = 0;
    endPointValue3 = 0;
    for (int ch = 0; ch < 3; ch++) {
      globalSum = 0;
      globalM = 0;
      globalB = 0;
      globalPos = 0;
      endPointIndex = 0;
      endPointValue = 0;
      startPointIndex = 0;
      startPointValue = 0;

      fitIndexData = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      sourceY = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      slopeValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0);
      fitMSlopeValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0);
      movingAverageValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      pdLeastSquareValue = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      baselineFittingData = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      dmReferenceArray = List.generate(TOTAL_CYCLE_INDEX, (i) => 0.0);
      averageValueList = List.generate(5, (i) => 0);

      // 2023.04.25_OSJ
      fitIndexData = await _indexCopyData(
          fitIndexData,
          TOTAL_CYCLE_INDEX,
          0,
          MEASURE_CYCLE_TIME/60,
          PRE_CYCLE_INDEX,
          PRE_CYCLE_TIME/60);// 2023.10.12_CJH
      if (fitIndexData.isNotEmpty) {
        // 2023.04.25_OSJ
        sourceY = await _copyData(sDataDouble, sourceY, ch, TOTAL_CYCLE_INDEX); // 2023.10.12_CJH

        if (sourceY.isNotEmpty) {
          // 2023.04.25_OSJ
          slopeValue = await _slope(sourceY, slopeValue, TOTAL_CYCLE_INDEX, M_START_INDEX); // 2023.10.12_CJH
          if (slopeValue.isNotEmpty) {
            // 2023.04.25_OSJ
            movingAverageValue = await _fitMovingAverage(
                slopeValue,
                TOTAL_CYCLE_INDEX,
                averageValueList,
                AVERAGE_VALUE_CYCLE,
                movingAverageValue,
                M_START_INDEX + 1); // 2023.10.12_CJH

            if (movingAverageValue.isNotEmpty) {
              // 2023.04.25_OSJ
              pdLeastSquareValue = await _pdLeastSquare(fitIndexData, sourceY,
                  TOTAL_CYCLE_INDEX, pdLeastSquareValue, M_START_INDEX); // 2023.10.12_CJH
              if (pdLeastSquareValue.isNotEmpty) {
                // 2023.04.25_OSJ
                fitMSlopeValue = await _slope(
                    pdLeastSquareValue, fitMSlopeValue, TOTAL_CYCLE_INDEX, M_START_INDEX + 1); // 2023.10.12_CJH
                if (fitMSlopeValue.isNotEmpty) { // 2023.10.12_CJH
                  // 2023.04.25_OSJ
                  endPointValue = await _baseLineEndPoint(
                      sourceY,
                      slopeValue,
                      pdLeastSquareValue,
                      fitMSlopeValue,
                      TOTAL_CYCLE_INDEX,
                      fitIndexData,
                      3,
                      10,
                      // 2023.10.10_CJH
                      8,
                      50,
                      30,
                      dmReferenceArray,
                      movingAverageValue);
                  // 2023.04.28_OSJ
                  // 2023.08.21_CJH
                  startPointValue = await _baselineStartPoint(
                      sourceY,
                      slopeValue,
                      movingAverageValue,
                      fitMSlopeValue,
                      fitIndexData,
                      80,
                      8);

                  globalM = await _baselineLeastSquare(fitIndexData, sourceY,
                      startPointIndex, (endPointIndex - startPointIndex + 1));

                  // 2023.04.25_OSJ
                  baselineFittingData = await _baselineFitting(sourceY,
                      baselineFittingData, fitIndexData, TOTAL_CYCLE_INDEX, 5);
                  if (baselineFittingData.isNotEmpty) {
                    // final ctValue = int.parse((sigmoidPos[0] +
                    //         (sigmoidPos[1] *
                    //             double.parse(
                    //                 cleoDevice.crntCartridge!.ctValue)))
                    //     .floor()
                    //     .toString());
                    dData[ch] = baselineFittingData;
                    // 2023.04.25_OSJ
                    dData[3].add(double.parse((await _getCtValue(
                            baselineFittingData,
                            fitIndexData,
                            TOTAL_CYCLE_INDEX,
                            int.parse(ctValue)))
                        .toStringAsFixed(1)));
                  }
                  // 2023.08.21_CJH
                  if (ch == 0) {
                    startPointValue1 = startPointValue;
                    endPointValue1 = endPointValue;
                  } else if (ch == 1) {
                    startPointValue2 = startPointValue;
                    endPointValue2 = endPointValue;
                  } else if (ch == 2) {
                    startPointValue3 = startPointValue;
                    endPointValue3 = endPointValue;
                  }
                } //CTVALUE 각 시약마다 다르므로 앱에서 전송해줘야함. Covid-19 -> CTValue = 50;
              }
            }
          }
        }
      }
    }
    return dData; // fitting data result value
  }
}
