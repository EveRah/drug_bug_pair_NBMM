# Drug-bug pair name (if new combination, create new drug-bug pair names)

if(species == "E_coli" & name_atb_class == "FQ"){
  pair = "FR-Ec"
} else if(species == "E_coli" & (name_atb_class == "3GC" | name_atb_class == "Ceftriaxone")){
  pair = "3GCR-Ec"
} else if(species == "E_coli" & name_atb_class == "AP"){
  pair = "APR-Ec"
} else if (species == "K_pneumoniae" & (name_atb_class == "3GC" | name_atb_class == "Ceftriaxone")){
  pair = "3GCR-Kp"
} else if(species == "K_pneumoniae" & name_atb_class == "CP"){
  pair = "CR-Kp"
} else if(species == "P_aeruginosa" & name_atb_class == "CP"){
  pair = "CR-Pa"
} else if(species == "A_baumannii" & name_atb_class == "CP"){
  pair = "CR-Ab"
} else if(species == "S_pneumoniae" & name_atb_class == "P"){
  pair = "PR-Sp"
} else if(species == "E_faecalis_E_faecium" & name_atb_class == "V"){
  pair = "VR-E"
  
  ###########################################################################
                                ## mock data ##
  
} else if(species == "mockSpecies" & name_atb_class == "mockAtb"){
  pair = "mockPair"
} else if(species == "mockSpecies2" & name_atb_class == "mockAtb2"){
  pair = "mockPair2"
}