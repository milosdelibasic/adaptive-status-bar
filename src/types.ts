/** Icon color, `light` is white icons for dark content. */
export type IconStyle = 'light' | 'dark';

/**
 * - `automatic`: pixel sampling decides, hints are ignored.
 * - `hybrid`: a screen's hint is used while it is set, sampling covers everything else. Default.
 * - `manual`: no sampling at all. Hints, overrides and fallback appearance apply.
 */
export type DetectionStrategy = 'automatic' | 'hybrid' | 'manual';

/** Sampling presets. See the README for the exact intervals. */
export type PerformanceMode = 'battery' | 'balanced' | 'responsive';

export type HysteresisThresholds = {
  /** Lightness (0..1, CIE L*) below which icons turn white. Default 0.42. */
  darkThreshold: number;
  /** Lightness (0..1, CIE L*) above which icons turn dark. Default 0.58. */
  lightThreshold: number;
};

export type AdaptiveStatusBarConfig = {
  /** Default `hybrid`. */
  strategy?: DetectionStrategy;
  /** Default `balanced`. */
  performance?: PerformanceMode;
  /** Fastest sampling interval in ms, used while the content under the status bar changes. */
  samplingInterval?: number;
  /** Slowest interval in ms while the app keeps drawing but the strip stays the same. */
  maxInterval?: number;
  /**
   * Longest interval in ms after the strip has stayed the same for a while, for apps whose main
   * thread never fully sleeps. Touches (iOS) and changed readings reset to `samplingInterval`.
   */
  quietInterval?: number;
  /**
   * Fallback sample in ms when nothing draws at all. 0 turns it off. Default 0, except 2000 in
   * `responsive`. Content that changes without drawing (video) usually can't be captured anyway.
   */
  idleInterval?: number;
  /** `true` uses 0.42 / 0.58, `false` switches at the midpoint, or pass your own thresholds. Default `true`. */
  hysteresis?: boolean | HysteresisThresholds;
  /** Samples in a row that must agree before a switch near a threshold. Default 2. */
  confirmSamples?: number;
  /** Minimum ms between two switches. Default 250. */
  minTransitionInterval?: number;
  /** Crossfade the icons on iOS. Android switches instantly either way. Default `true`. */
  animation?: boolean;
  /**
   * Style used when nothing else decides, e.g. manual mode with no hint.
   * On Android API 24–25, omission uses the active window's Android UI mode:
   * white icons in night mode, dark icons otherwise. Set this explicitly for custom JS themes.
   * On iOS and Android API 26+, omission leaves the status bar alone until another source decides.
   */
  fallbackStyle?: IconStyle;
  ios?: {
    /**
     * `automatic` (default) uses cheap layer capture, switching to UIKit hierarchy capture
     * when a visible Metal/OpenGL surface intersects the status bar. Explicit modes remain available.
     */
    captureMethod?: 'automatic' | 'layer' | 'hierarchy';
  };
};

export type StyleSource = 'sample' | 'override' | 'hint' | 'fallback';

export type StyleChangeEvent = {
  style: IconStyle;
  source: StyleSource;
  /** Last measured lightness, 0..1. Null before the first sample. */
  lightness: number | null;
};

/** Diagnostics. Counters are cumulative since the module loaded or the last `resetStats()`. */
export type AdaptiveStatusBarStats = {
  /** Last successful capture path on iOS. Absent on Android, null before the first sample. */
  iosCaptureMethod?: 'layer' | 'hierarchy' | null;
  /**
   * Whether the platform supports automatic sampling and appearance control.
   * False on Android API 24–25,
   * where fallback, hints and overrides can still control icon appearance.
   */
  supported: boolean;
  enabled: boolean;
  paused: boolean;
  /**
   * True while automatic sampling activity listeners are installed; not a capture-in-flight flag.
   * False on Android API 24–25 even while draw/focus listeners maintain fallback appearance.
   */
  sampling: boolean;
  style: IconStyle | null;
  /** Icon appearance reported by the active system status bar. */
  observedStyle: IconStyle | null;
  source: StyleSource | 'none';
  strategy: DetectionStrategy;
  /** Current sampling interval in ms. */
  intervalMs: number;
  samples: number;
  failures: number;
  /** Ticks skipped for a hidden status bar, missing window, or incomplete UIKit capture. */
  skipped: number;
  styleChanges: number;
  /** Times something else changed the status bar style and it was put back. */
  externalWrites: number;
  /** Activity callbacks received (frames drawn on Android, run loop turns on iOS). */
  activitySignals: number;
  /**
   * iOS: rendering the strip on the main thread. Android: the asynchronous PixelCopy round trip,
   * which runs off the main thread and includes waiting for the GPU.
   */
  captureMsAvg: number;
  captureMsMax: number;
  analysisMsAvg: number;
  analysisMsMax: number;
  /** Main thread time per sample, everything included. This is the number that can cost frames. */
  mainThreadMsAvg: number;
  mainThreadMsMax: number;
  lightness: number | null;
  left: number | null;
  right: number | null;
};

export type NativeConfig = {
  strategy: string;
  performance: string;
  samplingInterval?: number;
  maxInterval?: number;
  quietInterval?: number;
  idleInterval?: number;
  hysteresis: boolean;
  darkThreshold?: number;
  lightThreshold?: number;
  confirmSamples?: number;
  minTransitionInterval?: number;
  animation: boolean;
  fallbackStyle?: string;
  iosCaptureMethod?: string;
};
