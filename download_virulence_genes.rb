#!/usr/bin/env ruby

require 'bio'
require 'crack'
require 'open-uri'

#Initialize variables
Bio::NCBI.default_email = "(joshearl1@hotmail.com)"
ncbi = Bio::NCBI::REST.new
results = []

#Read in the list of gene names (also possible EC#'s will be parsed)
gene_names = File.read('gene_list.txt').split(%r{,\s*|\s+|\n})

# get an array of Gene IDs using Elink
gene_names.each_entry do |g|
  if \\.match(g)
    #TODO add in code for matching an EC#
    

  elsif \\.match(g)
    #TODO add in code matching to a Kegg id
  
  else
    results.concat ncbi.esearch("#{g}[Gene Name] AND Bacteria[Filter]", 
                                { "db"      => "gene", 
                                  "rettype" => "gb", 
                                  "retmode" => "text"
                                }
                                )
  end
end



base_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=protein&id="
all_fasta_seqs = ""

results.each_entry do |e|
  g = open(base_url + e).read
  g = Crack::XML.parse(g)
  #Add in some rudimentry checks to make sure we are getting a result from the web
  next unless !g.empty?
  puts "There was no result for #{e}" if g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id'].nil?
  next unless !g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id'].nil?

  #Everything checks out, so add the gene results 
  nucl_id = g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id']
  all_fasta_seqs = all_fasta_seqs + ncbi.efetch(nucl_id, {"db"=>"nucleotide", "rettype"=>"fasta", "retmode"=>"text"})
  all_fasta_seqs + "\n"
end

File.open('vir_genes.gb', 'w')   {|f| f.write(prots)}
File.open('vir_genes.fasta','w') {|f| f.write(prots)}
gb_saks = Bio::FlatFile.new(Bio::GenBank, 'vir_genes.gb')
gb_saks.each_entry do |e|
  puts e
end
