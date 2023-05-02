trash(can, 0).
platoSuc(plato, 0).
contarPlaLav(plato, 0).

+hay_basura(rlimpiador, trash, plato) [source(rmayordomo)]
   <- 
   	  +platosSucios;
	  ?contarPlaLav(plato, C);
	  D=C+1;
      !recogerBasura(rlimpiador, trash);
      !tirarBasura(rlimpiador, bin);
	  !recogerPlatoSucio(rlimpiador, plato);
	  !dejarPlato(rlimpiador, lavavajillas);
      .println("El robot limpiador vuelve a su posición");
      !go_at(rlimpiador, baseRLimpiador);
	  !hay_papeleraBin(rbasurero, bin);
      .abolish(hay_basura(rlimpiador, trash, plato));
	  .send(rmayordomo, achieve, limpiezaTerminada);
	  -+contarPlaLav(plato,D);
	  if(D >= 4){
	  	!hay_platosLavavajillas(rlavador, plato);
	  }.


+!hay_papeleraBin(rbasurero, bin) <-
	.send(rbasurero, tell, papelera_llena(rbasurero, bin));
	.wait(100);
	.send(rbasurero, untell, papelera_llena(rbasurero, bin)).

+!hay_platosLavavajillas(rlavador, plato) <-
	.send(rlavador, tell, lavavajillas_lleno(rlavador, lavavajillas));
	.wait(100);
	.send(rlavador, untell, lavavajillas_lleno(rlavador, lavavajillas)).

+!recogerBasura(rlimpiador, trash) : trashInEnv(T) & T > 0
   <- .println("El robot limpiador va a buscar basura");
      !go_at(rlimpiador, trash);
      .println("El robot limpiador recoge basura");
      pickTrash(rlimpiador, trash);
      ?trash(can, C);
      -+trash(can, C+1);
      !recogerBasura(rlimpiador,trash).
+!recogerBasura(rlimpiador, trash).

+!tirarBasura(rlimpiador, bin): trash(can, X) & X>0
   <- !go_at(rlimpiador, bin);
      !desechar(rlimpiador, trash).
+!tirarBasura(rlimpiador, bin).

+!desechar(rlimpiador, trash) : trash(can, X) & X>0
   <- desechar(rlimpiador, trash);
      -+trash(can, X-1);
      !desechar(rlimpiador, trash).
+!desechar(rlimpiador,trash)
   <- .println("El robot limpiador ha depositado toda la basura en el cubo").


+!recogerBasuraOwner(Elem, Cantidad) [source(owner)] : true
   <- ?trash(Elem, C);
      -trash(Elem, C);
      +trash(Elem, C+Cantidad).

+!recogerPlatoSucio(rlimpiador,plato) : platosSucios
   <-
     .println("El robot limpiador va a buscar el plato sucio");
      !go_at(rlimpiador, couch);
      .println("El robot limpiador recoge el plato");
      pickPlato(rlimpiador, plato);
      ?platoSuc(plato, E);
      -+platoSuc(plato, E+1);
	  -platosSucios;
      !recogerPlatoSucio(rlimpiador,plato).
+!recogerPlatoSucio(rlimpiador,plato).

+!dejarPlato(rlimpiador, lavavajillas): platoSuc(plato, F) & F>0
   <- !go_at(rlimpiador, lavavajillas);
      !desecharP(rlimpiador, plato).
+!dejarPlato(rlimpiador, lavavajillas).

+!desecharP(rlimpiador, plato) : platoSuc(plato, F) & F>0
   <- desecharP(rlimpiador, plato);
      -+platoSuc(plato, F-1);
      !desecharP(rlimpiador, plato).
+!desecharP(rlimpiador,plato)
   <- .println("El robot limpiador ha depositado todos los platos en el lavavajillas").


+!go_at(rlimpiador,P) : at(rlimpiador,P) <- true.
+!go_at(rlimpiador,P) : not at(rlimpiador,P)
  <- move_towards(P);
     !go_at(rlimpiador,P).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).