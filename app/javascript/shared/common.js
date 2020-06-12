import _ from 'lodash';

import 'shared/routes';

// undefine global lodash; see https://github.com/lodash/lodash/issues/2550
if (window.davidrunger) {
  _.noConflict();
}
