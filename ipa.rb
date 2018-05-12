require_relative 'lib/ipa_wiki'

# Download tables
tables = IPAwiki::Downloader.new.extract_tables
raise "Unexpected tables extracted" unless tables.size == 2
tables[0].to_tsv("data/ipa_vowels.tsv")
tables[1].to_tsv("data/ipa_consonants.tsv")
