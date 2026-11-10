import type { AdaptiveStatusBarConfig, NativeConfig } from './types';

const STRATEGIES = ['automatic', 'hybrid', 'manual'];
const PERFORMANCE = ['battery', 'balanced', 'responsive'];
const STYLES = ['light', 'dark'];

const fail = (message: string): never => {
  throw new RangeError(`[@skyvist/adaptive-status-bar] ${message}`);
};

const checkNumber = (
  name: string,
  value: number | undefined,
  min: number,
  max: number,
) => {
  if (value === undefined) return;
  if (
    typeof value !== 'number' ||
    !Number.isFinite(value) ||
    value < min ||
    value > max
  ) {
    fail(
      `${name} must be a number between ${min} and ${max}, got ${String(value)}`,
    );
  }
};

/** Shared shape checks run before configure() merges partial options. */
export const validateConfigShape = (config: AdaptiveStatusBarConfig): void => {
  if (config === null || typeof config !== 'object' || Array.isArray(config)) {
    fail('config must be an object');
  }
  if (config.animation !== undefined && typeof config.animation !== 'boolean') {
    fail('animation must be a boolean');
  }
  if (
    config.ios !== undefined &&
    (config.ios === null ||
      typeof config.ios !== 'object' ||
      Array.isArray(config.ios))
  ) {
    fail('ios must be an object');
  }
  if (
    config.hysteresis !== undefined &&
    typeof config.hysteresis !== 'boolean' &&
    (config.hysteresis === null ||
      typeof config.hysteresis !== 'object' ||
      Array.isArray(config.hysteresis))
  ) {
    fail('hysteresis must be a boolean or a thresholds object');
  }

};

/** Validates the config and flattens it for native. Throws a RangeError on bad input. */
export const toNativeConfig = (
  config: AdaptiveStatusBarConfig,
): NativeConfig => {
  validateConfigShape(config);

  const {
    strategy = 'hybrid',
    performance = 'balanced',
    samplingInterval,
    maxInterval,
    quietInterval,
    idleInterval,
    hysteresis = true,
    confirmSamples,
    minTransitionInterval,
    animation = true,
    fallbackStyle,
    ios,
  } = config;

  if (!STRATEGIES.includes(strategy)) fail(`unknown strategy "${strategy}"`);
  if (!PERFORMANCE.includes(performance))
    fail(`unknown performance mode "${performance}"`);
  if (fallbackStyle !== undefined && !STYLES.includes(fallbackStyle)) {
    fail(`fallbackStyle must be "light" or "dark"`);
  }
  checkNumber('samplingInterval', samplingInterval, 16, 10000);
  checkNumber('maxInterval', maxInterval, 16, 60000);
  checkNumber('quietInterval', quietInterval, 16, 60000);
  checkNumber('idleInterval', idleInterval, 0, 600000);
  checkNumber('minTransitionInterval', minTransitionInterval, 0, 10000);
  checkNumber('confirmSamples', confirmSamples, 1, 10);
  if (confirmSamples !== undefined && !Number.isInteger(confirmSamples)) {
    fail('confirmSamples must be an integer');
  }
  const preset =
    performance === 'battery'
      ? [250, 1000, 3000]
      : performance === 'responsive'
        ? [50, 150, 300]
        : [100, 300, 900];
  const effectiveMin = samplingInterval ?? preset[0];
  const effectiveMax = maxInterval ?? Math.max(preset[1], effectiveMin);
  const effectiveQuiet = quietInterval ?? Math.max(preset[2], effectiveMax);
  if (effectiveMax < effectiveMin)
    fail('maxInterval must be at least samplingInterval');
  if (effectiveQuiet < effectiveMax)
    fail('quietInterval must be at least maxInterval');
  if (idleInterval !== undefined && idleInterval > 0 && idleInterval < 100) {
    fail('idleInterval must be 0 (off) or at least 100 ms');
  }
  if (
    ios?.captureMethod !== undefined &&
    !['automatic', 'layer', 'hierarchy'].includes(ios.captureMethod)
  ) {
    fail(`unknown ios.captureMethod "${ios.captureMethod}"`);
  }

  let thresholds: { darkThreshold?: number; lightThreshold?: number } = {};
  if (typeof hysteresis === 'object') {
    if (
      typeof hysteresis.darkThreshold !== 'number' ||
      typeof hysteresis.lightThreshold !== 'number'
    ) {
      fail('hysteresis requires numeric darkThreshold and lightThreshold');
    }
    checkNumber('hysteresis.darkThreshold', hysteresis.darkThreshold, 0, 1);
    checkNumber('hysteresis.lightThreshold', hysteresis.lightThreshold, 0, 1);
    if (hysteresis.darkThreshold > hysteresis.lightThreshold) {
      fail(
        'hysteresis.darkThreshold must not exceed hysteresis.lightThreshold',
      );
    }
    thresholds = hysteresis;
  }

  return {
    strategy,
    performance,
    samplingInterval,
    maxInterval,
    quietInterval,
    idleInterval,
    hysteresis: hysteresis !== false,
    darkThreshold: thresholds.darkThreshold,
    lightThreshold: thresholds.lightThreshold,
    confirmSamples,
    minTransitionInterval,
    animation,
    fallbackStyle,
    iosCaptureMethod: ios?.captureMethod,
  };
};
