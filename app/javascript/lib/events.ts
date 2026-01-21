import { http } from '@/lib/http';
import { api_events_path } from '@/rails_assets/routes';

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
    navigator.sendBeacon(
      _api_events_path,
      new Blob([JSON.stringify(payload)], { type: 'application/json' }),
    );
  } else {
    http.post(_api_events_path, payload);
  }
}
