import { TurboModuleRegistry } from 'react-native';

import type { TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  enable(config: string): void;
  configure(config: string): void;
  disable(): void;
  setOverride(style: string | null): void;
  setHint(style: string | null): void;
  getStats(): Promise<string>;
  resetStats(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>(
  'SkyvistAdaptiveStatusBar',
);
