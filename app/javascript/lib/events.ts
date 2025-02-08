import { api_events_path } from '@/rails_assets/routes';
import { http } from '@/shared/http';

export function trackEvent(
  type: string,
  data: object,
  options: { useSendBeacon?: boolean } = { useSendBeacon: false },
): void {
  const _api_events_path = api_events_path();
  const payload = {
    type,
    data,
  };

  if (options.useSendBeacon) {
    // NOTE: uBlock Origin (and probably others) block sendBeacon requests, so
    // this tracking is not 100% reliable.
    navigator.sendBeacon(_api_events_path, JSON.stringify(payload));
  } else {
    http.post(_api_events_path, payload);
  }
}
