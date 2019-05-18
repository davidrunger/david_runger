import _ from 'lodash';

import 'shared/routes';

// undefine global lodash (except for tests); see https://github.com/lodash/lodash/issues/2550
if (window.davidrunger && window.davidrunger.env !== 'test') {
  _.noConflict();
}
