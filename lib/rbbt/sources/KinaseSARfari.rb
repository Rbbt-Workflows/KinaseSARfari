require 'rbbt-util'
require 'rbbt/resource'
require 'rbbt/sources/organism'

module KinaseSARfari
  extend Resource
  self.subdir = 'share/databases/KinaseSARfari'

  def self.organism(org="Hsa")
    Organism.default_code(org)
  end

  #self.search_paths = {}
  #self.search_paths[:default] = :lib


  KinaseSARfari.claim KinaseSARfari.protein, :proc do 
    TSV.open("ftp://ftp.ebi.ac.uk/pub/databases/chembl/KinaseSARfari/latest/ks_protein.txt.gz", :header_hash => "", :type => :double, :namespace => KinaseSARfari.organism, :sep2 => /\s*,\s+/)
  end

  KinaseSARfari.claim KinaseSARfari.compound, :proc do 
    TSV.open("ftp://ftp.ebi.ac.uk/pub/databases/chembl/KinaseSARfari/latest/ks_compound.txt.gz", :header_hash => "", :type => :list, :namespace => KinaseSARfari.organism)
  end

  KinaseSARfari.claim KinaseSARfari.bioactivity, :proc do 
    TSV.open("ftp://ftp.ebi.ac.uk/pub/databases/chembl/KinaseSARfari/latest/ks_bioactivity.txt.gz", :header_hash => "", :type => :list, :namespace => KinaseSARfari.organism)
  end

  def self.dom_id(uniprot)
    KinaseSARfari.protein.index(:fields => ["ACCESSIONS"], :persist => true, :persist_update => true)[uniprot]
  end

  def self.kinase_bioactivity(uniprot)
    dom_id = dom_id uniprot
    return nil if dom_id.nil?
    fields = %w(COMPOUND_ID ACTIVITY_TYPE RELATION STANDARD_VALUE STANDARD_UNIT PUBMED_ID)
    KinaseSARfari.bioactivity.tsv(:key_field => "DOM_ID", :type => :double, :merge => true, :fields => fields, :persist => true, :zipped => true)[dom_id]
  end
end

#ppp KinaseSARfari.protein.produce(true).index :fields => ["ACCESSIONS"] if __FILE__ == $0
#Log.tsv KinaseSARfari.compound.produce.tsv if __FILE__ == $0
#Log.tsv KinaseSARfari.bioactivity.produce.tsv if __FILE__ == $0

iii KinaseSARfari.kinase_bioactivity("P07949") if __FILE__ == $0

