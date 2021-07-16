RSpec.describe Relaton::Registry do
  it "outputs backend not present" do
    stub_const "Relaton::Registry::SUPPORTED_GEMS", ["not_supported_gem"]
    expect { Relaton::Registry.clone.instance }.to output(
      /backend not_supported_gem not present/,
    ).to_stderr
  end

  it "finds ISO processor" do
    expect(Relaton::Registry.instance.find_processor("relaton_iso"))
      .to be_instance_of RelatonIso::Processor
  end

  it "returns supported processors" do
    expect(Relaton::Registry.instance.supported_processors).to include :relaton_iso
  end

  context "finds processor by type" do
    it "CN" do
      expect(Relaton::Registry.instance.by_type("CN")).to be_instance_of RelatonGb::Processor
    end

    it "IEC" do
      expect(Relaton::Registry.instance.by_type("IEC")).to be_instance_of RelatonIec::Processor
    end

    it "IETF" do
      expect(Relaton::Registry.instance.by_type("IETF")).to be_instance_of RelatonIetf::Processor
    end

    it "ISO" do
      expect(Relaton::Registry.instance.by_type("ISO")).to be_instance_of RelatonIso::Processor
    end

    it "ITU" do
      expect(Relaton::Registry.instance.by_type("ITU")).to be_instance_of RelatonItu::Processor
    end

    it "NIST" do
      expect(Relaton::Registry.instance.by_type("NIST")).to be_instance_of RelatonNist::Processor
    end

    it "OGC" do
      expect(Relaton::Registry.instance.by_type("OGC")).to be_instance_of RelatonOgc::Processor
    end

    it "CC" do
      expect(Relaton::Registry.instance.by_type("CC")).to be_instance_of RelatonCalconnect::Processor
    end

    it "OMG" do
      expect(Relaton::Registry.instance.by_type("OMG")).to be_instance_of RelatonOmg::Processor
    end

    it "UN" do
      expect(Relaton::Registry.instance.by_type("UN")).to be_instance_of RelatonUn::Processor
    end

    it "W3C" do
      expect(Relaton::Registry.instance.by_type("W3C")).to be_instance_of RelatonW3c::Processor
    end

    it "IEEE" do
      expect(Relaton::Registry.instance.by_type("IEEE")).to be_instance_of RelatonIeee::Processor
    end

    it "IHO" do
      expect(Relaton::Registry.instance.by_type("IHO")).to be_instance_of RelatonIho::Processor
    end

    it "BIPM" do
      expect(Relaton::Registry.instance.by_type("BIPM")).to be_instance_of RelatonBipm::Processor
    end

    it "ECMA" do
      expect(Relaton::Registry.instance.by_type("ECMA")).to be_instance_of RelatonEcma::Processor
    end

    it "CIE" do
      expect(Relaton::Registry.instance.by_type("CIE")).to be_instance_of RelatonCie::Processor
    end

    it "BSI" do
      expect(Relaton::Registry.instance.by_type("BSI")).to be_instance_of RelatonBsi::Processor
    end

    it "CEN" do
      expect(Relaton::Registry.instance.by_type("CEN")).to be_instance_of RelatonCen::Processor
    end
  end
end
