# The name of this file uses lexicographical ordering. See:
# https://stackoverflow.com/a/38927158/4009384 . To determine a new filename for
# insertion, see: https://runkit.com/davidrunger/667b2a5707d6c60008d1fe66 .

# This avoids "DEPRECATION WARNING: Initialization autoloaded the constant RedisOptions."
require Rails.root.join('app/poros/redis_options.rb')
