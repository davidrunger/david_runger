# frozen_string_literal: true

require 'csv' # for Logs::UploadsController
require 'digest/sha1' # for ApplicationWorker uniqueness enforcement
require 'fileutils' # assets:precompile
require 'set' # MailgunViaHttp#safe_to_value
