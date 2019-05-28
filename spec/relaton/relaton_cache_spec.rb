require "spec_helper"
require "fileutils"

RSpec.describe Relaton::DbCache do
  it "creates default caches" do
    FileUtils.mv File.expand_path("~/.relaton"), "relaton1", force: true
    FileUtils.rm_rf %w("relaton")
    Relaton::DbCache.init_bib_caches(global_cache: true, local_cache: "")
    expect(File.exist?(File.expand_path("~/.relaton"))).to be true
    expect(File.exist?("relaton")).to be true
    FileUtils.mv "relaton1", File.expand_path("~/.relaton")
  end
end
