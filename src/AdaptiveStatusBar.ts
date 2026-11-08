import { toNativeConfig } from './config';
import Native from './specs/NativeSkyvistAdaptiveStatusBar';
import { StyleStack } from './StyleStack';
import type {
  AdaptiveStatusBarConfig,
  AdaptiveStatusBarStats,
  IconStyle,
} from './types';

let config: AdaptiveStatusBarConfig = {};
let enabled = false;
const imperativeKey = {};
const overrides = new StyleStack(style => Native.setOverride(style));
const hints = new StyleStack(style => Native.setHint(style));

export const AdaptiveStatusBar = {
  enable: (options: AdaptiveStatusBarConfig = {}): void => {
    const flat = toNativeConfig(options);
    config = options;
    enabled = true;
    Native.enable(JSON.stringify(flat));
  },
  disable: (): void => {
    enabled = false;
    Native.disable();
  },
  configure: (options: AdaptiveStatusBarConfig): void => {
    const next = {
      ...config,
      ...options,
      ios: { ...config.ios, ...options.ios },
    };
    const flat = toNativeConfig(next);
    config = next;
    if (enabled) Native.configure(JSON.stringify(flat));
  },
  get isEnabled(): boolean {
    return enabled;
  },
  get config(): Readonly<AdaptiveStatusBarConfig> {
    return config;
  },
  setOverride: (style: IconStyle): void => overrides.set(imperativeKey, style),
  clearOverride: (): void => overrides.set(imperativeKey, null),
  setHint: (style: IconStyle | null): void => hints.set(imperativeKey, style),
  getStats: async (): Promise<AdaptiveStatusBarStats> =>
    JSON.parse(await Native.getStats()),
  resetStats: (): void => Native.resetStats(),
};

export const stacks = { overrides, hints };
