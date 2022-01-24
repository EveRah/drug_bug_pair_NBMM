# Dictionaries for bacterial species names, antibiotic classes and MIC breakpoints standards

#create dictionary for bacterial species (add bacterial species if you need to)
species_dictionary <- hash()

species_dictionary[["0"]] <- "mockSpecies"
species_dictionary[["00"]] <- "mockSpecies2"

species_dictionary[["1"]] <- "E_coli"
species_dictionary[["2"]] <- "K_pneumoniae"
species_dictionary[["3"]] <- "P_aeruginosa"
species_dictionary[["4"]] <- "A_baumannii"
species_dictionary[["5"]] <- "E_faecalis_E_faecium"
species_dictionary[["6"]] <- "S_pneumoniae"

#print(species_dictionary)

#create dictionary for antibiotic classes (add antibiotic classes if you need to)
antibiotic_dictionary <- hash()

antibiotic_dictionary[["0"]] <- "mockAtb"
antibiotic_dictionary[["00"]] <- "mockAtb2"

antibiotic_dictionary[["1"]] <- "FQ"
antibiotic_dictionary[["2"]] <- "AP"
antibiotic_dictionary[["3"]] <- "3GC"
antibiotic_dictionary[["4"]] <- "CP"
antibiotic_dictionary[["5"]] <- "V"
antibiotic_dictionary[["6"]] <- "P"

#print(antibiotic_dictionary)

