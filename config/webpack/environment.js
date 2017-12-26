const { environment } = require('@rails/webpacker');

// the following loaders are manually configured in environment-specific configs
environment.loaders.set('vue', {});
environment.loaders.set('css', {}); // configured as `style` in environment-specific configs
environment.loaders.set('sass', {}); // configured as `style` in environment-specific configs

module.exports = environment;
