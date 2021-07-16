RSpec.describe Relaton::Db do
  before :each do
    FileUtils.rm_rf %w(testcache testcache2)
    @db = Relaton::Db.new "testcache", "testcache2"
  end

  it "rejects an illegal reference prefix" do
    expect { @db.fetch("XYZ XYZ", nil, {}) }.to output(
      /does not have a recognised prefix/,
    ).to_stderr
  end

  context "gets an ISO reference" do
    it "and caches it" do
      VCR.use_cassette "iso_19115_1" do
        bib = @db.fetch("ISO 19115-1", nil, {})
        expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
        expect(bib.to_xml(bibdata: true)).to include "<project-number>"\
          "ISO 19115</project-number>"
        expect(File.exist?("testcache")).to be true
        expect(File.exist?("testcache2")).to be true
        testcache = Relaton::DbCache.new "testcache"
        expect(testcache["ISO(ISO 19115-1)"]).to include "<project-number>"\
          "ISO 19115</project-number>"
        testcache = Relaton::DbCache.new "testcache2"
        expect(testcache["ISO(ISO 19115-1)"]).to include "<project-number>"\
          "ISO 19115</project-number>"
      end
      bib = @db.fetch("ISO 19115-1", nil, {})
      expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
    end

    it "with year in code" do
      VCR.use_cassette "19133_2005" do
        bib = @db.fetch("ISO 19133:2005")
        expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
        expect(bib.to_xml).to include '<bibitem id="ISO19133-2005" '\
          'type="standard">'
        testcache = Relaton::DbCache.new "testcache"
        expect(
          testcache.valid_entry?("ISO(ISO 19133:2005)", Date.today.year.to_s),
        ).to eq Date.today.year.to_s
      end
    end

    context "all parts" do
      it "implicity" do
        VCR.use_cassette "iso_19115" do
          bib = @db.fetch("ISO 19115", nil, {})
          expect(bib.docidentifier[0].id).to eq "ISO 19115 (all parts)"
        end
      end

      it "explicity" do
        VCR.use_cassette "iso_19115" do
          bib = @db.fetch("ISO 19115 (all parts)", nil, {})
          expect(bib.docidentifier[0].id).to eq "ISO 19115 (all parts)"
        end
      end
    end

    it "gets sn ISO/AWI reference" do
      VCR.use_cassette "iso_awi_14093" do
        bib = @db.fetch "ISO/AWI 14093"
        expect(bib).not_to be_nil
      end
    end
  end

  context "IEC" do
    it "get by reference" do
      VCR.use_cassette "iec_60050_102_2007" do
        bib = @db.fetch "IEC 60050-102:2007"
        expect(bib.docidentifier[0].id).to eq "IEC 60050-102:2007"
      end
    end

    it "get by URN" do
      VCR.use_cassette "iec_60050_102_2007" do
        bib = @db.fetch "urn:iec:std:iec:60050-102:2007:::"
        expect(bib.docidentifier[0].id).to eq "IEC 60050-102:2007"
      end
    end
  end

  context "NIST references" do
    before(:each) do
      nist_fr = /\.relaton\/nist\/pubs-export\.zip/
      expect(File).to receive(:exist?).with(nist_fr).and_return false
      expect(File).to receive(:exist?).and_call_original.at_least :once
      # expect(FileUtils).to receive(:mv).with kind_of(String), nist_fr
    end

    it "gets FISP" do
      VCR.use_cassette "fisp_140" do
        bib = @db.fetch "NIST FIPS 140"
        expect(bib).to be_instance_of RelatonNist::NistBibliographicItem
      end
    end

    it "gets SP" do
      VCR.use_cassette "sp_800_38b" do
        bib = @db.fetch "NIST SP 800-38B"
        expect(bib).to be_instance_of RelatonNist::NistBibliographicItem
      end
    end
  end

  it "deals with a non-existant ISO reference" do
    VCR.use_cassette "iso_111111119115_1" do
      bib = @db.fetch("ISO 111111119115-1", nil, {})
      expect(bib).to be_nil
      expect(File.exist?("testcache")).to be true
      expect(File.exist?("testcache2")).to be true
      testcache = Relaton::DbCache.new "testcache"
      expect(testcache.fetched("ISO(ISO 111111119115-1)")).to eq Date.today.to_s
      expect(testcache["ISO(ISO 111111119115-1)"]).to include "not_found"
      testcache = Relaton::DbCache.new "testcache2"
      expect(testcache.fetched("ISO(ISO 111111119115-1)")).to eq Date.today.to_s
      expect(testcache["ISO(ISO 111111119115-1)"]).to include "not_found"
    end
  end

  it "list all elements as a serialization" do
    VCR.use_cassette "iso_19115_1_2", match_requests_on: [:path] do
      @db.fetch "ISO 19115-1", nil, {}
      @db.fetch "ISO 19115-2", nil, {}
    end
    # file = "spec/support/list_entries.xml"
    # File.write file, @db.to_xml unless File.exist? file
    docs = Nokogiri::XML @db.to_xml
    expect(docs.xpath("/documents/bibdata").size).to eq 2
  end

  it "save/load/delete entry" do
    @db.save_entry "test key", "test value"
    expect(@db.load_entry("test key")).to eq "test value"
    expect(@db.load_entry("not existed key")).to be_nil
    @db.save_entry "test key", nil
    expect(@db.load_entry("test key")).to be_nil
    testcache = Relaton::DbCache.new "testcache"
    testcache.delete("test_key")
    testcache2 = Relaton::DbCache.new "testcache2"
    testcache2.delete("test_key")
    expect(@db.load_entry("test key")).to be_nil
  end

  context "get GB reference" do
    it "and cache it" do
      VCR.use_cassette "gb_t_20223_2006" do
        bib = @db.fetch "CN(GB/T 20223)", "2006", {}
        expect(bib).to be_instance_of RelatonGb::GbBibliographicItem
        expect(bib.to_xml(bibdata: true)).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
        expect(File.exist?("testcache")).to be true
        expect(File.exist?("testcache2")).to be true
        testcache = Relaton::DbCache.new "testcache"
        expect(testcache["CN(GB/T 20223:2006)"]).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
        testcache = Relaton::DbCache.new "testcache2"
        expect(testcache["CN(GB/T 20223:2006)"]).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
      end
    end

    it "with year" do
      VCR.use_cassette "gb_t_20223_2006" do
        bib = @db.fetch "CN(GB/T 20223-2006)", nil, {}
        expect(bib).to be_instance_of RelatonGb::GbBibliographicItem
        expect(bib.to_xml(bibdata: true)).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
        expect(File.exist?("testcache")).to be true
        expect(File.exist?("testcache2")).to be true
        testcache = Relaton::DbCache.new "testcache"
        expect(testcache["CN(GB/T 20223:2006)"]).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
        testcache = Relaton::DbCache.new "testcache2"
        expect(testcache["CN(GB/T 20223:2006)"]).to include <<~XML
          <project-number>GB/T 20223</project-number>
        XML
      end
    end
  end

  it "get RFC reference and cache it" do
    VCR.use_cassette "rfc_8341" do
      bib = @db.fetch "RFC 8341", nil, {}
      expect(bib).to be_instance_of RelatonIetf::IetfBibliographicItem
      expect(bib.to_xml).to include "<bibitem id=\"RFC8341\" type=\"standard\">"
      expect(File.exist?("testcache")).to be true
      expect(File.exist?("testcache2")).to be true
      testcache = Relaton::DbCache.new "testcache"
      expect(testcache["IETF(RFC 8341)"]).to include "<docidentifier "\
        "type=\"IETF\">RFC 8341</docidentifier>"
      testcache = Relaton::DbCache.new "testcache2"
      expect(testcache["IETF(RFC 8341)"]).to include "<docidentifier "\
        "type=\"IETF\">RFC 8341</docidentifier>"
    end
  end

  it "get OGC refrence and cache it" do
    VCR.use_cassette "ogc_19_025r1" do
      bib = @db.fetch "OGC 19-025r1", nil, {}
      expect(bib).to be_instance_of RelatonOgc::OgcBibliographicItem
    end
  end

  it "get Calconnect refrence and cache it" do
    cc_fr = /\.relaton\/calconnect\/bibliography\.yml/
    expect(File).to receive(:exist?).with(cc_fr).and_return false
    expect(File).to receive(:exist?).with(/etag\.txt/).and_return false
    expect(File).to receive(:exist?).and_call_original.at_least :once
    expect(File).to receive(:write).with(cc_fr, kind_of(String), kind_of(Hash))
      .at_most :once
    expect(File).to receive(:write).and_call_original.at_least :once
    VCR.use_cassette "cc_dir_10005_2019", match_requests_on: [:path] do
      bib = @db.fetch "CC/DIR 10005:2019", nil, {}
      expect(bib).to be_instance_of RelatonCalconnect::CcBibliographicItem
    end
  end

  it "get OMG reference" do
    VCR.use_cassette "omg_ami4ccm_1_0" do
      bib = @db.fetch "OMG AMI4CCM 1.0", nil, {}
      expect(bib).to be_instance_of RelatonOmg::OmgBibliographicItem
    end
  end

  it "get UN reference" do
    VCR.use_cassette "un_rtade_cefact_2004_32" do
      bib = @db.fetch "UN TRADE/CEFACT/2004/32", nil, {}
      expect(bib).to be_instance_of RelatonUn::UnBibliographicItem
    end
  end

  it "get W3C reference" do
    w3c_fr = /\.relaton\/w3c\/bibliography\.yml/
    expect(File).to receive(:exist?).with(w3c_fr).and_return false
    expect(File).to receive(:exist?).and_call_original.at_least :once
    expect(File).to receive(:write).with w3c_fr, kind_of(String), kind_of(Hash)
    # expect(File).to receive(:write).and_call_original.at_least :once
    VCR.use_cassette "w3c_json_ld11" do
      bib = @db.fetch "W3C JSON-LD 1.1", nil, {}
      expect(bib).to be_instance_of RelatonW3c::W3cBibliographicItem
    end
  end

  it "get IEEE reference" do
    VCR.use_cassette "ieee_528_2019" do
      bib = @db.fetch "IEEE 528-2019"
      expect(bib).to be_instance_of RelatonIeee::IeeeBibliographicItem
    end
  end

  it "get IHO reference" do
    VCR.use_cassette "iho_b_11" do
      bib = @db.fetch "IHO B-11"
      expect(bib).to be_instance_of RelatonIho::IhoBibliographicItem
    end
  end

  it "get ECMA reference" do
    VCR.use_cassette "ecma_6" do
      bib = @db.fetch "ECMA-6"
      expect(bib).to be_instance_of RelatonBib::BibliographicItem
    end
  end

  it "get CIE reference" do
    VCR.use_cassette "cie_001_1980" do
      bib = @db.fetch "CIE 001-1980"
      expect(bib).to be_instance_of RelatonBib::BibliographicItem
    end
  end

  it "get BSI reference" do
    VCR.use_cassette "bsi_bs_en_iso_8848" do
      bib = @db.fetch "BSI BS EN ISO 8848"
      expect(bib).to be_instance_of RelatonBsi::BsiBibliographicItem
    end
  end

  it "get CEN reference" do
    VCR.use_cassette "cen_en_10160_1999" do
      bib = @db.fetch "CEN EN 10160:1999"
      expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
    end
  end

  context "get combined documents" do
    context "ISO" do
      it "included" do
        VCR.use_cassette "iso_combined_included" do
          bib = @db.fetch "ISO 19115-1 + Amd 1"
          expect(bib.docidentifier[0].id).to eq "ISO 19115-1 + Amd 1"
          expect(bib.relation[0].type).to eq "updates"
          expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "ISO 19115-1"
          expect(bib.relation[1].type).to eq "derivedFrom"
          expect(bib.relation[1].description).to be_nil
          expect(bib.relation[1].bibitem.docidentifier[0].id).to eq "ISO 19115-1/Amd 1:2018"
        end
      end

      it "applied" do
        VCR.use_cassette "iso_combined_applied" do
          bib = @db.fetch "ISO 19115-1, Amd 1"
          expect(bib.docidentifier[0].id).to eq "ISO 19115-1, Amd 1"
          expect(bib.relation[0].type).to eq "updates"
          expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "ISO 19115-1"
          expect(bib.relation[1].type).to eq "complements"
          expect(bib.relation[1].description.content).to eq "amendment"
          expect(bib.relation[1].bibitem.docidentifier[0].id).to eq "ISO 19115-1/Amd 1:2018"
        end
      end
    end

    context "IEC" do
      it "included" do
        VCR.use_cassette "iec_combined_included" do
          bib = @db.fetch "IEC 60027-1, Amd 1, Amd 2"
          expect(bib.docidentifier[0].id).to eq "IEC 60027-1, Amd 1, Amd 2"
          expect(bib.relation[0].type).to eq "updates"
          expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "IEC 60027-1"
          expect(bib.relation[1].type).to eq "complements"
          expect(bib.relation[1].description.content).to eq "amendment"
          expect(bib.relation[1].bibitem.docidentifier[0].id).to eq "IEC 60027-1/AMD1:1997"
          expect(bib.relation[2].type).to eq "complements"
          expect(bib.relation[2].description.content).to eq "amendment"
          expect(bib.relation[2].bibitem.docidentifier[0].id).to eq "IEC 60027-1/AMD2:2005"
        end
      end
    end

    context "ITU" do
      it "included" do
        VCR.use_cassette "itu_combined_included" do
          bib = @db.fetch "ITU-T G.989.2, Amd 1, Amd 2"
          expect(bib.docidentifier[0].id).to eq "ITU-T G.989.2, Amd 1, Amd 2"
          expect(bib.relation[0].type).to eq "updates"
          expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "ITU-T G.989.2"
          expect(bib.relation[1].type).to eq "complements"
          expect(bib.relation[1].description.content).to eq "amendment"
          expect(bib.relation[1].bibitem.docidentifier[0].id).to eq "ITU-T G.989.2 Amd 1"
          expect(bib.relation[2].type).to eq "complements"
          expect(bib.relation[2].description.content).to eq "amendment"
          expect(bib.relation[2].bibitem.docidentifier[0].id).to eq "ITU-T G.989.2 Amd 2"
        end
      end
    end

    context "HIST" do
      it "included" do
        VCR.use_cassette "hist_combined_included" do
          bib = @db.fetch "NIST SP 800-38A, Add"
          expect(bib.docidentifier[0].id).to eq "NIST SP 800-38A, Add"
          expect(bib.relation[0].type).to eq "updates"
          expect(bib.relation[0].bibitem.docidentifier[0].id).to eq "SP 800-38A"
          expect(bib.relation[1].type).to eq "complements"
          expect(bib.relation[1].description.content).to eq "amendment"
          expect(bib.relation[1].bibitem.docidentifier[0].id).to eq "SP 800-38A-Add"
        end
      end
    end
  end

  context "version control" do
    before(:each) { @db.save_entry "iso(test_key)", "<bibitem><title>test_value</title></bibitem>" }

    it "shoudn't clear cache if version isn't changed" do
      testcache = @db.instance_variable_get :@db
      expect(testcache.all).to be_any
      testcache = @db.instance_variable_get :@local_db
      expect(testcache.all).to be_any
    end

    it "should clear cache if version is changed" do
      expect(File.read("testcache/iso/version", encoding: "UTF-8")).not_to eq "new_version"
      expect(File.read("testcache2/iso/version", encoding: "UTF-8")).not_to eq "new_version"
      processor = double
      expect(processor).to receive(:grammar_hash).and_return("new_version").exactly(2).times
      expect(Relaton::Registry.instance).to receive(:by_type).and_return(processor).exactly(2).times
      Relaton::Db.new "testcache", "testcache2"
      expect(File.exist?("testcache/iso/version")).to eq false
      expect(File.exist?("testcache2/iso/version")).to eq false
    end
  end

  context "api.relaton.org" do
    before(:each) do
      Relaton.configure do |config|
        config.use_api = true
        # config.api_host = "http://0.0.0.0:9292"
      end
    end

    after(:each) do
      Relaton.configure do |config|
        config.use_api = false
      end
    end

    it "get document" do
      VCR.use_cassette "api_relaton_org" do
        bib = @db.fetch "ISO 19115-2", "2019"
        expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
      end
    end

    it "if unavailable then get document directly" do
      expect(Net::HTTP).to receive(:get_response).and_wrap_original do |m, *args|
        raise Errno::ECONNREFUSED if args[0].host == "api.relaton.org"

        m.call(*args)
      end.at_least :once
      VCR.use_cassette "api_relaton_org_unavailable" do
        bib = @db.fetch "ISO 19115-2", "2019"
        expect(bib).to be_instance_of RelatonIsoBib::IsoBibliographicItem
      end
    end
  end
end
