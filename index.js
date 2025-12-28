import { Platform } from 'react-native';
import AppleAdsAttributionModule from './src/NativeAppleAdsAttribution';

class AppleAdsAttribution {
  getAttributionData() {
    if (Platform.OS !== 'ios') {
      return Promise.reject(new Error('AppleAdsAttribution is only available on iOS'));
    }
    if (!AppleAdsAttributionModule) {
      return Promise.reject(new Error('AppleAdsAttribution native module is not linked'));
    }
    return AppleAdsAttributionModule.getAttributionData();
  }

  getAdServicesAttributionToken() {
    if (Platform.OS !== 'ios') {
      return Promise.reject(new Error('AppleAdsAttribution is only available on iOS'));
    }
    if (!AppleAdsAttributionModule) {
      return Promise.reject(new Error('AppleAdsAttribution native module is not linked'));
    }
    return AppleAdsAttributionModule.getAdServicesAttributionToken();
  }

  getAdServicesAttributionData() {
    if (Platform.OS !== 'ios') {
      return Promise.reject(new Error('AppleAdsAttribution is only available on iOS'));
    }
    if (!AppleAdsAttributionModule) {
      return Promise.reject(new Error('AppleAdsAttribution native module is not linked'));
    }
    return AppleAdsAttributionModule.getAdServicesAttributionData();
  }
}

const AppleAdsAttributionInstance = new AppleAdsAttribution();

export default AppleAdsAttributionInstance;
