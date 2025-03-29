import { execSync } from 'child_process';
import activeAdminPlugin from '@activeadmin/activeadmin/plugin';

// Sometimes the first line is an info message about the path not having changed
// or something, so take `tail -1` to get the last line.
const activeAdminPath = execSync('bundle show activeadmin | tail -1', {
  encoding: 'utf-8',
}).trim();

export default {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/active_admin/**/*.{arb,erb,html,rb}',
    './app/views/admin/**/*.{arb,erb,html,rb}',
    './app/views/layouts/active_admin*.{erb,html}',
  ],
  darkMode: 'selector',
  plugins: [activeAdminPlugin],
};
