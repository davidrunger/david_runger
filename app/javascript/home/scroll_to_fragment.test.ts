import { setScrollToFragmentTimeouts } from './scroll_to_fragment';

describe('setScrollToFragmentTimeouts', () => {
  let fragmentTarget: HTMLElement;
  let scrollIntoView: ReturnType<
    typeof vi.fn<(arg?: boolean | ScrollIntoViewOptions) => void>
  >;

  beforeEach(() => {
    vi.useFakeTimers();

    fragmentTarget = document.createElement('div');
    fragmentTarget.id = 'links';
    scrollIntoView = vi.fn<(arg?: boolean | ScrollIntoViewOptions) => void>();
    fragmentTarget.scrollIntoView = scrollIntoView;
    document.body.append(fragmentTarget);
  });

  afterEach(() => {
    vi.useRealTimers();
    document.body.replaceChildren();
    window.history.replaceState({}, '', '/');
  });

  it('repeatedly scrolls to the fragment from the URL', () => {
    window.history.replaceState({}, '', '/#links');

    setScrollToFragmentTimeouts();

    expect(scrollIntoView).not.toHaveBeenCalled();

    vi.advanceTimersByTime(850);

    expect(scrollIntoView).toHaveBeenCalledTimes(5);
  });

  it('uses the provided fragment rather than the URL fragment', () => {
    window.history.replaceState({}, '', '/#not-in-the-dom');

    setScrollToFragmentTimeouts('links');
    vi.runAllTimers();

    expect(scrollIntoView).toHaveBeenCalledTimes(5);
  });
});
