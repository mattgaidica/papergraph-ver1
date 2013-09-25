#list nodes
START n=node(*)
RETURN n;

#delete
START n=node(*) 
MATCH n-[r?]-() 
DELETE n, r;