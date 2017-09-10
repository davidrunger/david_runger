import SmoothScroll from 'smooth-scroll/dist/js/smooth-scroll.min.js';
document.addEventListener('DOMContentLoaded', () => {
  var scroll = new SmoothScroll(
    'a[href*="#"]',
    {
      offset: 54,
    }
  );
});
