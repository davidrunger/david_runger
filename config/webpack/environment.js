const { environment } = require('@rails/webpacker');

// the following loaders are manually configured in environment-specific configs
environment.loaders.delete('css'); // configured as `style` in environment-specific configs
environment.loaders.delete('sass'); // configured as `style` in environment-specific configs
environment.loaders.delete('file'); // configured as `style` in environment-specific configs

module.exports = environment;
