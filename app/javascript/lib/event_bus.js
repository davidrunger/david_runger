// Currently, this is just a thin wrapper around addEventListener/dispatchEvent, for conciseness.
// This can be expanded in the future to include a payload, too.
// This would require using CustomEvent rather than Event, and possibly a polyfill for IE.

export function on(eventName, callback) {
  window.addEventListener(eventName, callback);
}

export function emit(eventName) {
  window.dispatchEvent(new Event(eventName));
}
