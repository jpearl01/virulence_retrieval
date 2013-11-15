#!/usr/bin/env ruby

require 'bio'
require 'crack'
require 'open-uri'
require 'yaml'

#Initialize variables
Bio::NCBI.default_email = "(joshearl1@hotmail.com)"
ncbi = Bio::NCBI::REST.new
results = []

#Read in the list of gene names (also possible EC#'s will be parsed)
gene_names = File.read('gene_list.txt').split(%r{,\s*|\s+|\n})

#We can actually get sequence straight from Kegg id's so lets keep them in a separate list for later
kegg_ids = []

=begin
# get an array of Gene IDs using Elink
gene_names.each_entry do |g|
  if ec_num = /EC?(\d+\.\d+\.\d+\.\d+)/.match(g)
    #I tend to use $1 as the variable for identifying a group match, but for clarity to others reading this who don't know perl, I'll use a 
    #more understandable syntax, i.e. "ec_num[1]"
    gid = ncbi.esearch("#{ec_num[1]}[EC] AND Bacteria[Filter]", { "db" => "gene", "rettype" => "gb", "retmode" => "text", "retmax" => 100 })    
    puts "No EC results for #{g}, searched using #{ec_num[1]}" if gid.empty?
    next if gid.empty?
    results.concat gid

  elsif /K\d+$/.match(g)
    #Unfortunately, the KEGG API has been deprecated since Dec 2012, I'll have to implement this with thier REST system.
    kegg_ids.push(g)
  
  else
    gid = ncbi.esearch("#{g}[Gene Name] AND Bacteria[Filter]", { "db" => "gene", "rettype" => "gb", "retmode" => "text", "retmax" => 100 })
    puts "No results for #{g}" if gid.empty?
    next if gid.empty?
    results.concat gid
  end
end

File.open("ncbi_esearch_results",'w'){|f| f.write(results.to_yaml)}
abort("Lets see what the NCBI gave back to us in the search results")
=end

base_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=gene&db=protein&id="
all_fasta_seqs = ""

results = YAML.load_file("ncbi_esearch_results")

results.each_entry do |e|
  #Create url to get xml results for this gid
  g = open(base_url + e).read
  g = Crack::XML.parse(g)

  #rescue if there is no result from the current elink result 
  begin
    nucl_id = g['eLinkResult']['LinkSet']['LinkSetDb'][-1]['Link']['Id']
    all_fasta_seqs = all_fasta_seqs + ncbi.efetch(nucl_id, {"db"=>"nucleotide", "rettype"=>"fasta", "retmode"=>"text"})
    all_fasta_seqs + "\n"  
  rescue
    puts "There was no result for #{e}"
    next
  end
  
end

#File.open('vir_genes.gb', 'w')   {|f| f.write(prots)}
File.open('vir_genes.fasta','w') {|f| f.write(all_fasta_seqs)}
gb_saks = Bio::FlatFile.new(Bio::GenBank, 'vir_genes.gb')
gb_saks.each_entry do |e|
  puts e
end

=begin
There was some error handling that may be handy later, but I don't need it now.

    next unless !g.empty?
    puts "There was no result for #{e}" if g.nil? or g['eLinkResult'].nil? or g['eLinkResult']['LinkSet']['LinkSetDb'][-1].nil?
    next if g.nil? or g['eLinkResult'].nil? or g['eLinkResult']['LinkSet']['LinkSetDb'][-1].nil?
=end
