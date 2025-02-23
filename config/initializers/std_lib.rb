require 'csv' # for LogsController, Logs::UploadsController
require 'digest/sha1' # for ApplicationWorker uniqueness enforcement
require 'fileutils' # assets:precompile
