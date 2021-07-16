require "fileutils"
require "timeout"

RSpec.describe Relaton::DbCache do
  it "creates default caches" do
    cache_path = File.expand_path("~/.relaton/cache")
    FileUtils.mv cache_path, "relaton1/cache", force: true
    FileUtils.rm_rf %w(relaton)
    Relaton::Db.init_bib_caches(
      global_cache: true, local_cache: "", flush_caches: true,
    )
    expect(File.exist?(cache_path)).to be true
    expect(File.exist?("relaton")).to be true
    FileUtils.mv "relaton1/cache", cache_path if File.exist? "relaton1"
  end

  it "write same file by concurent processes" do
    dir = "testcache/iso"
    FileUtils.mkdir_p dir unless File.exist? dir
    file_name = File.join dir, "iso_123.xml"
    file = File.open file_name, File::RDWR | File::CREAT, encoding: "UTF-8"
    file.flock File::LOCK_EX
    command = <<~RBY
      require "relaton"
      cache = Relaton::DbCache.new "testcache"
      cache["ISO(ISO 123)"] = "test 1"
    RBY
    pid = spawn RbConfig.ruby, "-e #{command}"
    sleep 0.1
    file.write "test 2"
    file.flock File::LOCK_UN
    file.close
    Process.waitpid pid, 0
    expect($?.exitstatus).to eq 0
    expect(File.read(file_name)).to eq "test 1"
    FileUtils.rm_rf "testcache"
  end
end
