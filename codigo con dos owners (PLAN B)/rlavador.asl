


+lavavajillas_lleno(rlavador, lavavajillas) [source(rlimpiador)]
    <-  !go_at(rlavador, lavavajillas);
		.println("Poniendo el lavavajillas");
		.wait(6000);
        vaciarLa(lavavajillas);
        !go_at(rlavador, lacena);
		ponerPla(rlavador, lacena);
		!go_at(rlavador, baseRLavador).
	
		
		
+!go_at(rlavador,P) : at(rlavador,P) <- true.
+!go_at(rlavador,P) : not at(rlavador,P) 
  <- move_towards(P);
     !go_at(rlavador,P).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
