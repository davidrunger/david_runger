/* eslint-disable max-len */
// modified from
// https://developers.google.com/speed/webp/faq#how_can_i_detect_browser_support_for_webp
const TEST_IMAGES = [
  'UklGRiIAAABXRUJQVlA4IBYAAAAwAQCdASoBAAEADsD+JaQAA3AAAAAA',
  'UklGRhoAAABXRUJQVlA4TA0AAAAvAAAAEAcQERGIiP4HAA==',
  'UklGRkoAAABXRUJQVlA4WAoAAAAQAAAAAAAAAAAAQUxQSAwAAAARBxAR/Q9ERP8DAABWUDggGAAAABQBAJ0BKgEAAQAAAP4AAA3AAP7mtQAAAA==',
  'UklGRlIAAABXRUJQVlA4WAoAAAASAAAAAAAAAAAAQU5JTQYAAAD/////AABBTk1GJgAAAAAAAAAAAAAAAAAAAGQAAABWUDhMDQAAAC8AAAAQBxAREYiI/gcA',
];
/* eslint-enable max-len */

// modified from
// https://developers.google.com/speed/webp/faq#how_can_i_detect_browser_support_for_webp
function parseWebpImage(base64Image) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => {
      if ((img.width > 0) && (img.height > 0)) {
        window.davidrunger.webpIsSupported = true;
        resolve();
      } else {
        window.davidrunger.webpIsSupported = false;
        reject();
      }
    };
    img.onerror = () => {
      window.davidrunger.webpIsSupported = false;
      reject();
    };
    img.src = `data:image/webp;base64,${base64Image}`;
  });
}

export default function checkWebpSupport() {
  const prediscoveredResult = window.davidrunger.webpIsSupported;
  if (prediscoveredResult !== undefined) {
    return Promise.resolve(prediscoveredResult);
  } else {
    return new Promise(resolve => {
      Promise.all(TEST_IMAGES.map(image => parseWebpImage(image))).
        then(() => resolve(true)).
        catch(() => resolve(false));
    });
  }
}
