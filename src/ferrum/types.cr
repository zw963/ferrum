record BrowserOption,
  port : Int32,
  messages : Array(SupervisorMessages),
  root : String,
  app_name : String,
  supervisor : NamedTuple(started_at: Int64, pid: Int64),
  instances : Hash(String, Array(InstanceConfig)),
  processes : Array(ControlClientProcessStatus),
  environment_variables : Hash(String, String),
  procfile_path : String,
  options_path : String,
  local_options_path : String,
  sock_path : String,
  supervisor_pid_path : String,
  pid_root : String,
  loaded_at : Int64,
  log_root : String? do
  include JSON::Serializable
end
