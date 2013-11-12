#!/usr/bin/env ruby

require 'bio'
require 'crack'
require 'open-uri'

Bio::NCBI.default_email = "(joshearl1@hotmail.com)"
ncbi = Bio::NCBI::REST.new

# get an array of Gene IDs using Elink
results = ncbi.esearch("sak[Gene Name] AND Bacteria[Filter]", {"db"=>"gene", "rettype"=>"gb", "retmode"=>"text"})
base_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=protein&id="

results.each_entry do |e|
  g = open(base_url + e).read
  g = Crack::XML.parse(g)
  nucl_id = g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id']
  seq = ncbi.efetch(nucl_id, {"db"=>"nucleotide", "rettype"=>"fasta", "retmode"=>"text"})
  puts seq
end

File.open('vir_genes.gb', 'w')   {|f| f.write(prots)}
File.open('vir_genes.fasta','w') {|f| f.write(prots)}
gb_saks = Bio::FlatFile.new(Bio::GenBank, 'vir_genes.gb')
gb_saks.each_entry do |e|
  puts e
end
