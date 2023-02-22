record BrowserBaseOption,
  port : String?,
  host : String?,
  timeout : Int32?,
  window_size : Tuple(Int32, Int32)?,
  js_errors : Bool?,
  headless : Bool?,
  pending_connection_errors : Bool?,
  process_timeout : Int32?,
  browser_options : Hash(String, String?)?,
  slowmo : Float64?,
  ws_max_receive_size : Int32?,
  env : Hash(String, String)?,
  proxy : Hash(String, String)?,
  logger : Log?,
  browser_name : String?,
  browser_path : String?,
  save_path : String?,
  extensions : Array(String)?,
  ignore_default_browser_options : Bool?,
  xvfb : Ferrum::Browser::Xvfb?,
  base_url : String?,
  url : String? do
  setter window_size

  def initialize
  end
end
