require 'open_calais'

# you can configure for all calls
OpenCalais.configure do |c|
  c.api_key = "22tj3w8adh5rs7wtv93wtqhy"
end

# or you can configure for a single call
open_calais = OpenCalais::Client.new(:api_key=>'22tj3w8adh5rs7wtv93wtqhy')

# it returns a OpenCalais::Response instance
response = open_calais.enrich('I. Introduction The basal ganglia connect the cerebral cortex with neural systems that effect behavior. Most cortical areas provide inputs to the basal ganglia, which in turn provide outputs to brain systems that are involved in the generation of behavior. Among the behavior effector systems targeted are thalamic nuclei that project to those frontal cortical areas involved in the planning and execution of movement; midbrain regions including the superior colliculus, which is involved in the generation of eye movements; the pedunculopontine nucleus, which is involved in orienting movements; and hypothalamic systems involved in autonomic functions. Two points concerning the function of the basal ganglia are emphasized. First, while the basal ganglia Handbook of Basal Ganglia Structure and Function.')

# which has the 'raw' response
response.raw

# and has been parsed a bit to get :language, :topics, :tags, :entities, :relations, :locations
# as lists of hashes
response.tags.each{|t| puts t[:name] }