class Dir
  def self.mktempdir(prefix : String? = nil, suffix : String? = nil)
    tempfile = File.tempfile(prefix, suffix)
    tempfile.delete
    Dir.mkdir_p(tempfile.path)
  end
end
