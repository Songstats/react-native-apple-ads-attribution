import { Platform } from 'react-native';
import AppleAdsAttributionModule from './src/NativeAppleAdsAttribution';

class AppleAdsAttribution {
  getAttributionData() {
    if (Platform.OS !== 'ios') {
      return null;
    }
    return AppleAdsAttributionModule.getAttributionData();
  }

  getAdServicesAttributionToken() {
    if (Platform.OS !== 'ios') {
      return null;
    }
    return AppleAdsAttributionModule.getAdServicesAttributionToken();
  }

  getAdServicesAttributionData() {
    if (Platform.OS !== 'ios') {
      return null;
    }
    return AppleAdsAttributionModule.getAdServicesAttributionData();
  }
}

const AppleAdsAttributionInstance = new AppleAdsAttribution();

export default AppleAdsAttributionInstance;
