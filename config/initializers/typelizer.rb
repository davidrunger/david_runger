Typelizer.reject_class =
  proc do |serializer:|
    serializer.in?([
      LogEntrySerializer, # This model is not backed by a single database table.
    ])
  end
