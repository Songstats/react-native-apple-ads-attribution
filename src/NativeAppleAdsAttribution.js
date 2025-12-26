// @flow

import type {TurboModule} from 'react-native';
import {NativeModules, Platform, TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  +getAttributionData: () => Promise<Object>;
  +getAdServicesAttributionToken: () => Promise<string>;
  +getAdServicesAttributionData: () => Promise<Object>;
}

const LINKING_ERROR =
  `The package '@hexigames/react-native-apple-ads-attribution' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ios: "- You have run 'pod install'\n", default: ''}) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const isTurboModuleEnabled = global.__turboModuleProxy != null;

const AppleAdsAttributionModule = isTurboModuleEnabled
  ? TurboModuleRegistry.getEnforcing<Spec>('AppleAdsAttribution')
  : NativeModules.AppleAdsAttribution;

if (!AppleAdsAttributionModule && Platform.OS === 'ios') {
  throw new Error(LINKING_ERROR);
}

export default ((AppleAdsAttributionModule || {}: any): Spec);
