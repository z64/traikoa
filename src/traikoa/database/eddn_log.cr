module Traikoa::Database
  class EddnLog < Jennifer::Model::Base
    table_name :eddn_logs

    mapping({
      id:                {type: Int32, primary: true},
      gateway_timestamp: {type: Time},
      type:              String,
      uploader_id:       String,
      software_name:     String,
      software_version:  String,
      schema_ref:        String,
      system_name:       {type: String, null: true},
      system_position:   {type: Array(Float64), null: true},
      station_name:      {type: String, null: true},
      message:           JSON::Any,
    })
  end
end
