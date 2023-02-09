// Currently, this is just a thin wrapper around addEventListener/dispatchEvent, for conciseness.
// This can be expanded in the future to include a payload, too.
// This would require using CustomEvent rather than Event, and possibly a polyfill for IE.

// returns a function that unsubscribes from the event
export function on(eventName: string, callback: () => void) {
  window.addEventListener(eventName, callback);
  return function unsubscribe() {
    window.removeEventListener(eventName, callback);
  };
}

export function emit(eventName: string) {
  window.dispatchEvent(new Event(eventName));
}
