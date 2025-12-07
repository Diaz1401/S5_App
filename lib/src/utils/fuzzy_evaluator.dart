// lib/src/utils/fuzzy_evaluator.dart
// Implementasi Fuzzy Mamdani untuk 3 input (pH, Salinity derived from TDS, turbidity)
// Output: kategori risiko {RSR, RR, RS, RT, RST} + nilai defuzzifikasi (0..100)

import 'dart:math';

typedef MF = double Function(double x);

class FuzzyEvaluator {
  // --- PUBLIC: panggil evaluate untuk mendapatkan hasil ---
  // returns Map: { 'label': 'RS'|'RR'|..., 'score': double (0..100) }
  static Map<String, dynamic> evaluate({
    required double ph,
    required double tds, // Input TDS dalam ppm (mg/L)
    required double turbidity,
  }) {
    // 0) Konversi TDS (ppm) ke Salinitas (ppt)
    // Rumus:
    // EC (uS/cm) = TDS (ppm) / 0.64
    // EC (mS/cm) = EC (uS/cm) / 1000
    // Salinity (ppt) = 0.4665 * (EC ^ 1.0878)
    // Source: https://www.sciencing.com/convert-specific-conductivity-salinity-5915328/
    final double ec_mS = (tds / 0.64) / 1000.0;
    final double salinity = 0.4665 * pow(ec_mS, 1.0878);

    // 1) Fuzzifikasi: hitung derajat keanggotaan tiap linguistic term
    final phMFs = _phMemberships(ph);
    final salMFs = _salinityMemberships(salinity);
    final turbMFs = _turbMemberships(turbidity);

    // 2) Rule base Mamdani (18 Rules)
    // pH (3) x Salinity (3) x Turbidity (2) = 18 rules
    // pH: L, N, H
    // Salinity: L, N, H
    // Turb: N, T (Normal, Turbid)

    final List<Map<String, dynamic>> rules = [
      // pH Normal
      {
        'if': {'ph': 'N', 'sal': 'N', 'turb': 'N'},
        'then': 'RSR',
      }, // Semua Normal -> Sangat Rendah
      {
        'if': {'ph': 'N', 'sal': 'N', 'turb': 'T'},
        'then': 'RS',
      }, // Turbid -> Sedang
      {
        'if': {'ph': 'N', 'sal': 'L', 'turb': 'N'},
        'then': 'RR',
      }, // Sal Low -> Rendah
      {
        'if': {'ph': 'N', 'sal': 'L', 'turb': 'T'},
        'then': 'RS',
      }, // Sal Low + Turbid -> Sedang
      {
        'if': {'ph': 'N', 'sal': 'H', 'turb': 'N'},
        'then': 'RR',
      }, // Sal High -> Rendah
      {
        'if': {'ph': 'N', 'sal': 'H', 'turb': 'T'},
        'then': 'RS',
      }, // Sal High + Turbid -> Sedang
      // pH Low
      {
        'if': {'ph': 'L', 'sal': 'N', 'turb': 'N'},
        'then': 'RS',
      }, // pH Low -> Sedang
      {
        'if': {'ph': 'L', 'sal': 'N', 'turb': 'T'},
        'then': 'RT',
      }, // pH Low + Turbid -> Tinggi
      {
        'if': {'ph': 'L', 'sal': 'L', 'turb': 'N'},
        'then': 'RT',
      }, // pH Low + Sal Low -> Tinggi
      {
        'if': {'ph': 'L', 'sal': 'L', 'turb': 'T'},
        'then': 'RST',
      }, // pH Low + Sal Low + Turbid -> Sangat Tinggi
      {
        'if': {'ph': 'L', 'sal': 'H', 'turb': 'N'},
        'then': 'RT',
      }, // pH Low + Sal High -> Tinggi
      {
        'if': {'ph': 'L', 'sal': 'H', 'turb': 'T'},
        'then': 'RST',
      }, // pH Low + Sal High + Turbid -> Sangat Tinggi
      // pH High
      {
        'if': {'ph': 'H', 'sal': 'N', 'turb': 'N'},
        'then': 'RS',
      }, // pH High -> Sedang
      {
        'if': {'ph': 'H', 'sal': 'N', 'turb': 'T'},
        'then': 'RT',
      }, // pH High + Turbid -> Tinggi
      {
        'if': {'ph': 'H', 'sal': 'L', 'turb': 'N'},
        'then': 'RT',
      }, // pH High + Sal Low -> Tinggi
      {
        'if': {'ph': 'H', 'sal': 'L', 'turb': 'T'},
        'then': 'RST',
      }, // pH High + Sal Low + Turbid -> Sangat Tinggi
      {
        'if': {'ph': 'H', 'sal': 'H', 'turb': 'N'},
        'then': 'RT',
      }, // pH High + Sal High -> Tinggi
      {
        'if': {'ph': 'H', 'sal': 'H', 'turb': 'T'},
        'then': 'RST',
      }, // pH High + Sal High + Turbid -> Sangat Tinggi
    ];

    // 3) Untuk setiap rule: hitung firing strength
    final Map<String, double> outputAggregation = {
      'RSR': 0.0,
      'RR': 0.0,
      'RS': 0.0,
      'RT': 0.0,
      'RST': 0.0,
    };

    for (final rule in rules) {
      final cond = rule['if'] as Map<String, String>;
      final outLabel = rule['then'] as String;

      final phDeg = phMFs[cond['ph']!] ?? 0.0;
      final salDeg = salMFs[cond['sal']!] ?? 0.0;
      final tbDeg = turbMFs[cond['turb']!] ?? 0.0;

      final firing = min(min(phDeg, salDeg), tbDeg); // AND = min
      // aggregate by maximum (Mamdani)
      outputAggregation[outLabel] = max(outputAggregation[outLabel]!, firing);
    }

    // 4) Defuzzifikasi
    final Map<String, double> outputCenters = {
      'RSR': 0.0,
      'RR': 25.0,
      'RS': 50.0,
      'RT': 75.0,
      'RST': 100.0,
    };

    double numerator = 0.0;
    double denominator = 0.0;
    outputAggregation.forEach((label, mu) {
      numerator += mu * outputCenters[label]!;
      denominator += mu;
    });

    final double score = (denominator == 0) ? 50.0 : (numerator / denominator);

    // find highest label by aggregated mu
    String bestLabel = 'RS';
    double bestMu = -1.0;
    outputAggregation.forEach((label, mu) {
      if (mu > bestMu) {
        bestMu = mu;
        bestLabel = label;
      }
    });

    return {
      'label': bestLabel,
      'score': double.parse(score.toStringAsFixed(2)),
      'aggregation': outputAggregation,
      'centers': outputCenters,
      'calculated_salinity': salinity, // Useful for debugging
    };
  }

  // ----------------------------
  // Membership functions per variabel
  // ----------------------------

  static Map<String, double> _phMemberships(double x) {
    // Sederhana: 7.5 - 8.5
    return {
      'L': _shoulderLeft(x, 7.0, 7.5),
      'N': _trapezoid(x, 7.0, 7.5, 8.5, 9.0),
      'H': _shoulderRight(x, 8.5, 9.0),
    };
  }

  static Map<String, double> _salinityMemberships(double x) {
    // Sederhana: Salinitas 5 - 40 ppt
    return {
      'L': _shoulderLeft(x, 4.0, 5.0),
      'N': _trapezoid(x, 4.0, 5.0, 40.0, 41.0),
      'H': _shoulderRight(x, 40.0, 41.0),
    };
  }

  static Map<String, double> _turbMemberships(double x) {
    return {
      'N': _shoulderLeft(x, 20.0, 25.0),
      'T': _shoulderRight(x, 20.0, 25.0),
    };
  }

  // ----------------------------
  // Basic membership shapes
  // ----------------------------

  static double _shoulderLeft(double x, double a, double b) {
    if (x <= a) return 1.0;
    if (x >= b) return 0.0;
    return (b - x) / (b - a);
  }

  static double _shoulderRight(double x, double a, double b) {
    if (x <= a) return 0.0;
    if (x >= b) return 1.0;
    return (x - a) / (b - a);
  }

  static double _trapezoid(double x, double a, double b, double c, double d) {
    if (x <= a || x >= d) return 0.0;
    if (x >= b && x <= c) return 1.0;
    if (x < b) return (x - a) / (b - a);
    return (d - x) / (d - c);
  }
}
