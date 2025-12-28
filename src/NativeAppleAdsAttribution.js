// @flow

import type { TurboModule } from 'react-native';
import { Platform, TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  +getAttributionData: () => Promise<Object>;
  +getAdServicesAttributionToken: () => Promise<string>;
  +getAdServicesAttributionData: () => Promise<Object>;
}

// Don’t resolve at module load time, and never on Android.
export default (Platform.OS === 'ios'
  ? TurboModuleRegistry.get<Spec>('AppleAdsAttribution')
  : null);
