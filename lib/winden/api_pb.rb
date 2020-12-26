# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: api.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("api.proto", :syntax => :proto3) do
    add_message "api.Request" do
      optional :start_ts, :uint64, 1
      optional :query, :string, 4
      map :vars, :string, :string, 5
      optional :read_only, :bool, 6
      optional :best_effort, :bool, 7
      repeated :mutations, :message, 12, "api.Mutation"
      optional :commit_now, :bool, 13
    end
    add_message "api.Uids" do
      repeated :uids, :string, 1
    end
    add_message "api.Response" do
      optional :json, :bytes, 1
      optional :txn, :message, 2, "api.TxnContext"
      optional :latency, :message, 3, "api.Latency"
      optional :metrics, :message, 4, "api.Metrics"
      map :uids, :string, :string, 12
    end
    add_message "api.Mutation" do
      optional :set_json, :bytes, 1
      optional :delete_json, :bytes, 2
      optional :set_nquads, :bytes, 3
      optional :del_nquads, :bytes, 4
      repeated :set, :message, 5, "api.NQuad"
      repeated :del, :message, 6, "api.NQuad"
      optional :cond, :string, 9
      optional :commit_now, :bool, 14
    end
    add_message "api.Operation" do
      optional :schema, :string, 1
      optional :drop_attr, :string, 2
      optional :drop_all, :bool, 3
      optional :drop_op, :enum, 4, "api.Operation.DropOp"
      optional :drop_value, :string, 5
      optional :run_in_background, :bool, 6
    end
    add_enum "api.Operation.DropOp" do
      value :NONE, 0
      value :ALL, 1
      value :DATA, 2
      value :ATTR, 3
      value :TYPE, 4
    end
    add_message "api.Payload" do
      optional :Data, :bytes, 1
    end
    add_message "api.TxnContext" do
      optional :start_ts, :uint64, 1
      optional :commit_ts, :uint64, 2
      optional :aborted, :bool, 3
      repeated :keys, :string, 4
      repeated :preds, :string, 5
    end
    add_message "api.Check" do
    end
    add_message "api.Version" do
      optional :tag, :string, 1
    end
    add_message "api.Latency" do
      optional :parsing_ns, :uint64, 1
      optional :processing_ns, :uint64, 2
      optional :encoding_ns, :uint64, 3
      optional :assign_timestamp_ns, :uint64, 4
      optional :total_ns, :uint64, 5
    end
    add_message "api.Metrics" do
      map :num_uids, :string, :uint64, 1
    end
    add_message "api.NQuad" do
      optional :subject, :string, 1
      optional :predicate, :string, 2
      optional :object_id, :string, 3
      optional :object_value, :message, 4, "api.Value"
      optional :label, :string, 5
      optional :lang, :string, 6
      repeated :facets, :message, 7, "api.Facet"
    end
    add_message "api.Value" do
      oneof :val do
        optional :default_val, :string, 1
        optional :bytes_val, :bytes, 2
        optional :int_val, :int64, 3
        optional :bool_val, :bool, 4
        optional :str_val, :string, 5
        optional :double_val, :double, 6
        optional :geo_val, :bytes, 7
        optional :date_val, :bytes, 8
        optional :datetime_val, :bytes, 9
        optional :password_val, :string, 10
        optional :uid_val, :uint64, 11
      end
    end
    add_message "api.Facet" do
      optional :key, :string, 1
      optional :value, :bytes, 2
      optional :val_type, :enum, 3, "api.Facet.ValType"
      repeated :tokens, :string, 4
      optional :alias, :string, 5
    end
    add_enum "api.Facet.ValType" do
      value :STRING, 0
      value :INT, 1
      value :FLOAT, 2
      value :BOOL, 3
      value :DATETIME, 4
    end
    add_message "api.LoginRequest" do
      optional :userid, :string, 1
      optional :password, :string, 2
      optional :refresh_token, :string, 3
    end
    add_message "api.Jwt" do
      optional :access_jwt, :string, 1
      optional :refresh_jwt, :string, 2
    end
  end
end

module Api
  Request = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Request").msgclass
  Uids = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Uids").msgclass
  Response = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Response").msgclass
  Mutation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Mutation").msgclass
  Operation = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Operation").msgclass
  Operation::DropOp = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Operation.DropOp").enummodule
  Payload = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Payload").msgclass
  TxnContext = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.TxnContext").msgclass
  Check = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Check").msgclass
  Version = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Version").msgclass
  Latency = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Latency").msgclass
  Metrics = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Metrics").msgclass
  NQuad = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.NQuad").msgclass
  Value = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Value").msgclass
  Facet = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Facet").msgclass
  Facet::ValType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Facet.ValType").enummodule
  LoginRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.LoginRequest").msgclass
  Jwt = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("api.Jwt").msgclass
end