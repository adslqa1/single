//---------------------------raw data에서 removeBubbleEffect 함수 적용하여 보정 처리 된 데이터를 fitting 함수 적용--------------------------
//removeBubbleEffect(fit_pd1_value_demo, fit_pd1_remove_bubble_value, TOTAL_CYCLE_INDEX);
import 'package:cleo/cleo_device/cleo_device.dart'; // 2023.10.12_CJH

class bubble {
  int fAvergeSize = 3;
  int rAvergeSize = 3;
  int FALLING = 0;
  int RISING = 1;
  int BOTH = 2;
  int CALIBRATION = 3;
  double SENSITIVITY = 0.5;

  static int min = CleoDevice.TEST_MIN.toInt(); // 2023.10.12_CJH
  static int arrayIndex = CleoDevice.SP_TEST_CYCLE + CleoDevice.TEST_CYCLE; // 2023.10.12_CJH
  static int startIdx = 5; // 2023.10.12_CJH

  List<double> sData_50 = List.generate(arrayIndex - startIdx, (i) => 0.0); // 2023.10.12_CJH
  List<List<double>> pNoiseData =
      List.generate(4, (index) => List.generate(arrayIndex - startIdx, (index) => 0.0)); // 2023.10.12_CJH

  Future<List<List<double>>> bubbleDataProcess( // 2023.10.12_CJH
      List<List<int>> sData, int maxCycle) async {
    List<List<double>> dData = // 2023.10.12_CJH
        List.generate(3, (index) => List.generate(arrayIndex, (index) => 0)); // 2023.09.11_CJH
    for (int ch = 0; ch < 3; ch++) {
      fAvergeSize = 3;
      rAvergeSize = 3;
      FALLING = 0;
      RISING = 1;
      BOTH = 2;
      CALIBRATION = 3;
      SENSITIVITY = 0.5;
      sData_50.clear();
      sData_50 = List.generate(arrayIndex - startIdx, (i) => 0.0); // 2023.10.12_CJH
      pNoiseData.clear();
      pNoiseData =
          List.generate(4, (index) => List.generate(arrayIndex - startIdx, (index) => 0.0)); // 2023.10.12_CJH

      dData[ch] = await removeBubbleEffect(sData[ch], dData[ch], maxCycle);
    }
    return dData;
  }

  Future<List<double>> removeBubbleEffect( // 2023.10.12_CJH
      List<int> sData, List<double> dData, int maxCycle) async { // 2023.10.12_CJH
    int i;
    int nCycle = maxCycle - startIdx;

    //sData_50 = List.generate(arrayIndex - startIdx, (i) => 0.0); // 2023.10.12_CJH
    //pNoiseData =
    //List.generate(4, (index) => List.generate(arrayIndex - startIdx, (index) => 0.0)); // 2023.10.12_CJH

    //List<double> sData_50 = List.generate(nCycle, (i) => 0.0);
    List<double> rmFNoiseData = List.generate(nCycle, (i) => 0.0);
    List<double> rmRNoiseData = List.generate(nCycle, (i) => 0.0);

    //System.Array.Copy(sData, startIdx, sData_50, 0, nCycle);
    for (i = startIdx; i < maxCycle; i++) {
      sData_50[i - startIdx] = sData[i].toDouble();
    }

    for (i = 3; i < nCycle; i++) {
      if (sData_50[i] == 0) {
        sData_50[i] = (sData_50[i - 1] + sData_50[i - 2] + sData_50[i - 3]) / 3;
      }
    }

    //List<List<double>> pNoiseData = List.generate(4, (index) => List.generate(nCycle, (index) => 0.0));
    //double rmFTh = -Convert.ToDouble(numericViewBubbleFalling.Value);
    //double rmRTh = Convert.ToDouble(numericViewBubbleRising.Value);
    double rmFTh = -10.toDouble();
    double rmRTh = 50.toDouble();

    //fallingNoise(ref sData_50, ref pNoiseData, nCycle, -50.0f, 50.0f);
    //risingNoise(ref sData_50, ref pNoiseData, nCycle, -50.0f, 50.0f);
    await fallingNoise(nCycle, -50.0, 50.0);
    await risingNoise(nCycle, -50.0, 50.0);

    await fallingNoise(nCycle, rmFTh, rmRTh);
    await risingNoise(nCycle, rmFTh, rmRTh);

    sData_50 = await noiseFilter(sData_50, nCycle);

    // for (i = 0; i < 2; i++) {
    //   //fallingNoise(ref sData_50, ref pNoiseData, nCycle, rmFTh, rmRTh);
    //   //risingNoise(ref sData_50, ref pNoiseData, nCycle, rmFTh, rmRTh);
    //   await fallingNoise(nCycle, rmFTh, rmRTh);
    //   await risingNoise(nCycle, rmFTh, rmRTh);
    // }

    // sData_50 = await lowpassfilter(sData_50, nCycle);
    // List<double> maData_50 = List.generate(nCycle, (i) => 0.0);
    // double maValue = 0;
    // int maCnt = 0;

    // for (i = 0; i < nCycle; i++) {
    //   maValue = 0;
    //   maCnt = 0;

    //   for (int j = i - 2; j < i + 3; j++) {
    //     if (j < 0) continue;
    //     if (j >= nCycle) continue;

    //     maValue += sData_50[j];
    //     maCnt++;
    //   }

    //   maData_50[i] = maValue / maCnt;
    // }

    //System.Array.Copy(maData_50, 0, dData, startIdx, nCycle);
    //System.Array.Copy(sData, 0, dData, 0, startIdx);

    for (int i = 0; i < maxCycle; i++) {
      if (i < startIdx) {
        dData[i] = sData[i].toDouble(); // 2023.10.12_CJH
      } else {
        dData[i] = sData_50[i - startIdx]; // 2023.10.12_CJH
      }
    }

    return dData;
  }

  Future<List<double>> noiseFilter(List<double> sData, int maxCycle) async {
    int i, j, k;
    double temp;

    List<double> cData = List.generate(maxCycle, (i) => 0.0);
    List<double> cDataO = List.generate(maxCycle, (i) => 0.0);
    List<double> cDataR = List.generate(maxCycle, (i) => 0.0);
    List<double> cDataC = List.generate(maxCycle, (i) => 0.0);

    for (i = 1; i < maxCycle; i++) {
      cData[i] = sData[i] - sData[i - 1];
    }

    cData[0] = cData[1];

    cDataO = [...cData]; // 2023.10.12_CJH
    cDataR = [...cData]; // 2023.10.12_CJH

    // cDataO = cData; //주소값 복사로인한 문제
    // cDataR = cData; //주소값 복사로인한 문제

    //System.Array.Copy(cData, 0, cDataO, 0, maxCycle);
    //System.Array.Copy(cData, 0, cDataR, 0, maxCycle);

    int Idx = maxCycle - 1;

    for (i = 0; i < (maxCycle / 2).toInt(); i++) {
      temp = cDataR[i];
      cDataR[i] = cDataR[Idx];
      cDataR[Idx] = temp;
      Idx--;
    }

    cDataR = await lowpassfilter(cDataR, maxCycle, SENSITIVITY);

    Idx = maxCycle - 1;
    for (i = 0; i < (maxCycle / 2).toInt(); i++) {
      temp = cDataR[i];
      cDataR[i] = cDataR[Idx];
      cDataR[Idx] = temp;
      Idx--;
    }

    cDataO = await lowpassfilter(cDataO, maxCycle, SENSITIVITY);

    for (i = 0; i < maxCycle; i++) {
      cDataC[i] = (cDataO[i] + cDataR[i]) / 2.0.toDouble();
      cData[i] = cDataC[i] + (cDataC[i] * 0.05.toDouble());
    }

    for (i = 1; i < maxCycle; i++) {
      sData[i] = cData[i] + sData[i - 1];
    }

    return sData;
  }

  Future<List<double>> lowpassfilter(
      List<double> sData, int maxCycle, double sens) async {
    int i;
    double fValue;

    fValue = sData[0];

    for (i = 1; i < maxCycle; i++) {
      fValue = (fValue * (1 - sens)) + (sData[i] * sens);
      sData[i] = fValue;
    }

    return sData;
  }

  //private void fallingNoise(ref List<double> sData, ref List<List<double>> noiseData, int maxCycle, double fT, double rT)
  Future fallingNoise(int maxCycle, double fT, double rT) async {
    int i, j, k;
    List<double> cData = List.generate(maxCycle, (i) => 0.0);

    for (i = 1; i < maxCycle; i++) {
      cData[i] = sData_50[i] - sData_50[i - 1];
    }

    cData[0] = cData[1];

    double divValue = 0;

    for (i = 1; i < 5; i++) {
      divValue = cData[i];

      for (j = 0; j < 5; j++) {
        if ((cData[i] < -10.0) || (cData[i] > 10.0)) {
          divValue = divValue / 10.0;
        }
      }
      cData[i] = divValue;
    }
    cData[0] = cData[1];

    for (i = 0; i < maxCycle; i++) {
      pNoiseData[CALIBRATION][i] = cData[i];
    }

    for (i = 0; i < maxCycle; i++) {
      if (cData[i] < fT || cData[i] > rT) {
        pNoiseData[BOTH][i] = cData[i];
      } else {
        pNoiseData[BOTH][i] = 0;
      }

      if (cData[i] < fT) {
        pNoiseData[FALLING][i] = cData[i];
      } else {
        pNoiseData[FALLING][i] = 0;
      }

      if (cData[i] > rT) {
        pNoiseData[RISING][i] = cData[i];
      } else {
        pNoiseData[RISING][i] = 0;
      }
    }

    int sIdx = 0;
    int sPNIdx = 0;
    int ePNIdx = 0;
    int mValueCnt = 0;
    int pValueCnt = 0;
    double sum = 0;
    double newData = 0;
    int sumCnt = 0;

    for (i = sIdx; i < maxCycle - 1; i++) {
      if (pNoiseData[BOTH][i] == 0) {
        if (pNoiseData[BOTH][i + 1] != 0) {
          sPNIdx = i;
          ePNIdx = 0;
          for (j = sPNIdx + 1; j < maxCycle; j++) {
            if (j == 0) continue;
            if (pNoiseData[BOTH][j] == 0) {
              ePNIdx = j;
              break;
            }
          }
        }
      }

      if (ePNIdx > sPNIdx) {
        sIdx = ePNIdx;

        mValueCnt = 0;
        pValueCnt = 0;
        sum = 0;
        newData = 0;
        sumCnt = 0;

        for (j = sPNIdx; j < ePNIdx; j++) {
          if (pNoiseData[FALLING][j] != 0) mValueCnt++;
          if (pNoiseData[RISING][j] != 0) pValueCnt++;
        }
        
        if (mValueCnt >= (pValueCnt / 2).toInt()) {
          for (j = sPNIdx; j > (sPNIdx - 3); j--) {
            if (j < 0) break;
            if (pNoiseData[FALLING][j] != 0) continue;
            if (pNoiseData[RISING][j] != 0) continue;
            sum += cData[j];
            sumCnt++;
          }
          for (j = ePNIdx; j < ePNIdx + 3; j++) {
            if (j >= maxCycle) break;
            if (pNoiseData[FALLING][j] != 0) continue;
            if (pNoiseData[RISING][j] != 0) continue;
            sum += cData[j];
            sumCnt++;
          }

          if (sumCnt == 0) {
            sPNIdx = 0;
            ePNIdx = 0;
            continue;
          }

          newData = ((sum / sumCnt) / (ePNIdx - sPNIdx));

          for (j = sPNIdx + 1; j < ePNIdx; j++) {
            pNoiseData[CALIBRATION][j] = newData;
          }
          sPNIdx = 0;
          ePNIdx = 0;
        } else {
          if (mValueCnt == 0) continue;

          int sMIdx = 0;
          int eMIdx = 0;

          for (j = sPNIdx; j < ePNIdx; j++) {
            if (pNoiseData[RISING][j] == 0) {
              if (pNoiseData[FALLING][j + 1] != 0) {
                sMIdx = j;
                eMIdx = 0;
                for (k = sPNIdx + 1; k < ePNIdx + 1; k++) {
                  if (k >= maxCycle) break;

                  if (pNoiseData[FALLING][k] == 0) {
                    if ((k + 1) < maxCycle) {
                      eMIdx = k;
                    }
                    break;
                  }
                }

                if (eMIdx == ePNIdx) eMIdx = 0;
              }
            }

            if (eMIdx > sMIdx) {
              sPNIdx = eMIdx;
              for (k = sMIdx; k > (sMIdx - 3); k--) {
                if (k < 0) break;
                if (pNoiseData[RISING][k] == 0) continue;

                sum += cData[k];
                sumCnt++;
              }
              for (k = eMIdx; k < sMIdx + 3; k++) {
                if (k >= maxCycle) break;
                if (pNoiseData[RISING][k] == 0) continue;

                sum += cData[j];
                sumCnt++;
              }

              if (sumCnt == 0) {
                sMIdx = 0;
                eMIdx = 0;
                continue;
              }

              newData = ((sum / sumCnt) / (eMIdx - sMIdx));

              for (k = sMIdx + 1; k < eMIdx; k++) {
                pNoiseData[CALIBRATION][k] = newData;
              }
            }
          }
        }
      }
    }

    for (i = 1; i < maxCycle; i++) {
      sData_50[i] = sData_50[i - 1] + pNoiseData[CALIBRATION][i];
    }
  }

  Future risingNoise(int maxCycle, double fT, double rT) async {
    int i, j;
    List<double> cData = List.generate(maxCycle, (i) => 0.0);
    List<double> ccData = List.generate(maxCycle, (i) => 0.0);

    //System.Array.Clear(noiseData, 0, noiseData.Length);
    pNoiseData.clear();
    pNoiseData = List.generate(4, (index) => List.generate(arrayIndex - startIdx, (index) => 0.0));  // 2023.10.12_CJH 75 -> arrayIndex - 5

    for (i = 1; i < maxCycle; i++) {
      cData[i] = sData_50[i] - sData_50[i - 1];
    }
    cData[0] = cData[1];

    double divValue = 0;

    for (i = 1; i < 5; i++) {
      divValue = cData[i];

      for (j = 0; j < 5; j++) {
        if ((cData[i] < -10.0) || (cData[i] > 10.0)) {
          divValue = divValue / 10.0;
        }
      }
      cData[i] = divValue;
    }
    cData[0] = cData[1];

    for (i = 1; i < maxCycle; i++) {
      ccData[i] = cData[i] - cData[i - 1];
    }
    ccData[0] = ccData[1];

    for (i = 0; i < maxCycle; i++) {
      pNoiseData[CALIBRATION][i] = cData[i];
    }

    for (i = 0; i < maxCycle; i++) {
      if (ccData[i] > rT) {
        pNoiseData[RISING][i] = ccData[i];
      } else {
        pNoiseData[RISING][i] = 0;
      }
    }

    int sIdx = 0;
    int sPNIdx = 0;
    int ePNIdx = 0;
    int mValueCnt = 0;
    int pValueCnt = 0;
    double sum = 0;
    double newData = 0;
    int sumCnt = 0;

    for (i = sIdx; i < maxCycle - 1; i++) {
      if (pNoiseData[RISING][i] == 0) {
        if (pNoiseData[RISING][i + 1] != 0) {
          sPNIdx = i;
          ePNIdx = 0;
          for (j = sPNIdx + 1; j < maxCycle; j++) {
            if (j == 0) continue;
            if (pNoiseData[RISING][j] == 0) {
              ePNIdx = j;
              break;
            }
          }
        }
      }

      if (ePNIdx > sPNIdx) {
        mValueCnt = 0;
        pValueCnt = 0;
        sum = 0;
        newData = 0;
        sumCnt = 0;
        sIdx = ePNIdx;
        for (j = sPNIdx; j < ePNIdx; j++) {
          if (pNoiseData[FALLING][j] < 0) mValueCnt++;
          if (pNoiseData[RISING][j] > 0) pValueCnt++;
        }

        if (pValueCnt > 0) {
          for (j = sPNIdx; j > (sPNIdx - 3); j--) {
            if (j < 0) break;
            if (pNoiseData[RISING][j] != 0) continue;

            sum += cData[j];
            sumCnt++;
          }
          for (j = ePNIdx; j < ePNIdx + 3; j++) {
            if (j >= maxCycle) break;
            if (pNoiseData[RISING][j] != 0) continue;

            sum += cData[j];
            sumCnt++;
          }

          newData = (sum / sumCnt);

          for (j = sPNIdx + 1; j < ePNIdx; j++) {
            pNoiseData[CALIBRATION][j] = newData;
          }

          sPNIdx = 0;
          ePNIdx = 0;
        }
      }
    }

    for (i = 1; i < maxCycle; i++) {
      sData_50[i] = sData_50[i - 1] + pNoiseData[CALIBRATION][i];
    }
  }
}
