const m = Element.prototype.matches || Element.prototype.matchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector || Element.prototype.webkitMatchesSelector;

export function matches(element, selector) {
  if (selector.exclude != null) {
    return m.call(element, selector.selector) && !m.call(element, selector.exclude);
  } else {
    return m.call(element, selector);
  }
}

export function delegate(element, selector, eventType, handler) {
  return element.addEventListener(eventType, function(e) {
    var target;
    target = e.target;
    while (!(!(target instanceof Element) || matches(target, selector))) {
      target = target.parentNode;
    }
    if (target instanceof Element && handler.call(target, e) === false) {
      e.preventDefault();
      return e.stopPropagation();
    }
  });
};
