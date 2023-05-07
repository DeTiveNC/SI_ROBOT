


+papelera_llena(rbasurero, bin) [source(Agt)]
    <-  !go_at(rbasurero, bin);
        vaciar(bin);
		burnerOn;
        !go_at(rbasurero, baseRBasurero);
		burnerOff.
	
		
		
+!go_at(rbasurero,P) : at(rbasurero,P) <- true.
+!go_at(rbasurero,P) : not at(rbasurero,P) 
  <- move_towards(P);
     !go_at(rbasurero,P).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
