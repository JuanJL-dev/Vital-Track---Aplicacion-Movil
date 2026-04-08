import 'dart:math';

class RandomWalkGenerator {
  final Random _random = Random();
  final Map<String, double> _currentValues = {};

  double generate({
    required String key,
    required double min,
    required double max,
    double volatility = 0.5,
    double stepSize = 2.0,
  }) {
    if (!_currentValues.containsKey(key)) {
      _currentValues[key] = min + (max - min) / 2;
    }

    final currentValue = _currentValues[key]!;
    final change = (_random.nextDouble() * 2 - 1) * stepSize;
    final noise = (_random.nextDouble() * 2 - 1) * volatility;

    final newValue = currentValue + change + noise;

    final clampedValue = newValue.clamp(min, max);
    _currentValues[key] = clampedValue;

    return clampedValue;
  }

  double generateCorrelated({
    required String key,
    required double min,
    required double max,
    required double previousValue,
    double volatility = 0.5,
    double stepSize = 2.0,
  }) {
    final change = (_random.nextDouble() * 2 - 1) * stepSize;
    final noise = (_random.nextDouble() * 2 - 1) * volatility;

    final newValue = previousValue + change + noise;
    final clampedValue = newValue.clamp(min, max);
    _currentValues[key] = clampedValue;

    return clampedValue;
  }

  void reset(String key) {
    _currentValues.remove(key);
  }

  void resetAll() {
    _currentValues.clear();
  }

  double getCurrentValue(String key) {
    return _currentValues[key] ?? 0.0;
  }

  void setInitialValue(String key, double value) {
    _currentValues[key] = value;
  }

  List<double> generateSequence({
    required String key,
    required double min,
    required double max,
    required int length,
    double volatility = 0.5,
    double stepSize = 2.0,
  }) {
    final List<double> sequence = [];

    for (int i = 0; i < length; i++) {
      final value = generate(
        key: key,
        min: min,
        max: max,
        volatility: volatility,
        stepSize: stepSize,
      );
      sequence.add(value);
    }

    return sequence;
  }

  List<double> generateHistoricalSequence({
    required String key,
    required double min,
    required double max,
    required int count,
    double volatility = 0.3,
    double stepSize = 1.5,
  }) {
    reset(key);

    final List<double> sequence = [];
    final baseValue = min + (max - min) / 2;
    setInitialValue(key, baseValue);
    sequence.add(baseValue);

    for (int i = 1; i < count; i++) {
      final value = generate(
        key: key,
        min: min,
        max: max,
        volatility: volatility,
        stepSize: stepSize,
      );
      sequence.add(value);
    }

    return sequence;
  }
}
