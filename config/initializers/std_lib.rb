require 'English' # $CHILD_STATUS and other named global variables
require 'csv' # for LogsController, Logs::UploadsController
require 'digest/sha1' # for ApplicationWorker uniqueness enforcement
require 'fileutils' # assets:precompile
