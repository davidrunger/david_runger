import { routes } from '@/lib/routes';
import { http } from '@/shared/http';

export function trackEvent(
  type: string,
  data: object,
  options: { useSendBeacon?: boolean } = { useSendBeacon: false },
): void {
  const api_events_path = routes.api_events_path();
  const payload = {
    type,
    data,
  };

  if (options.useSendBeacon) {
    // NOTE: uBlock Origin (and probably others) block sendBeacon requests, so
    // this tracking is not 100% reliable.
    navigator.sendBeacon(api_events_path, JSON.stringify(payload));
  } else {
    http.post(api_events_path, payload);
  }
}
