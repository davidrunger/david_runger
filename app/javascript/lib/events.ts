import { routes } from '@/lib/routes';

export function trackEvent(type: string, data: object): void {
  // NOTE: uBlock Origin (and probably others) block sendBeacon requests, so
  // this tracking is not 100% reliable.
  navigator.sendBeacon(
    routes.api_events_path(),
    JSON.stringify({
      type,
      data,
    }),
  );
}
