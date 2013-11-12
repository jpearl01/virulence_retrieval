#!/usr/bin/env ruby

require 'bio'
require 'crack'
require 'open-uri'

Bio::NCBI.default_email = "(joshearl1@hotmail.com)"
ncbi = Bio::NCBI::REST.new
results = ncbi.esearch("sak[Gene Name] AND Bacteria[Filter]", {"db"=>"gene", "rettype"=>"gb", "retmode"=>"text"})

results.each_entry do |e|
  g = open('http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=protein&id=' + e).read
  g = Crack::XML.parse(g)
  nucl_id = g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id']
  seq = ncbi.efetch(nucl_id, {"db"=>"nucleotide", "rettype"=>"fasta", "retmode"=>"text"})
  puts seq
end
