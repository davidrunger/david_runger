import { isElement } from '@/lib/typePredicates';

export function delegate(
  parent: Element | Document,
  type: string,
  selector: string,
  handler: (event: Event, target: Element) => void,
): () => void {
  const listener = (event: Event) => {
    const target = event.target;

    if (isElement(target) && target.matches(selector)) {
      handler(event, target);
    }
  };

  parent.addEventListener(type, listener);

  return () => parent.removeEventListener(type, listener);
}
