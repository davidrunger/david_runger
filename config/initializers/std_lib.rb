require 'csv' # for LogsController, Logs::UploadsController
require 'digest' # for ApplicationWorker uniqueness enforcement, gravatar URL
require 'fileutils' # assets:precompile
require 'uri' # CSP report origin validation
