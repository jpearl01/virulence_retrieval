#!/usr/bin/env ruby

require 'bio'
Bio::NCBI.default_email = "(joshearl1@hotmail.com)"
ncbi = Bio::NCBI::REST.new
results = ncbi.esearch("sak[Gene Name] AND Bacteria[Filter]", {"db"=>"gene", "rettype"=>"gb", "retmode"=>"text"})
prots = ncbi.efetch(ids = results, {"db"=>"nucleotide", "rettype"=>"gb", "retmode"=>"text"})

prots.gsub!("\n\n", "\n")

File.open('vir_genes.gb', 'w')   {|f| f.write(prots)}
File.open('vir_genes.fasta','w') {|f| f.write(prots)}
gb_saks = Bio::FlatFile.new(Bio::GenBank, 'vir_genes.gb')
gb_saks.each_entry do |e|
  puts e
end
