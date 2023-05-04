trash(can, 0).


+hay_basura(rlimpiador, trash) [source(rmayordomo)]
   <- 
      !recogerBasura(rlimpiador, trash);
      !tirarBasura(rlimpiador, bin);
      .println("El robot limpiador vuelve a su posición");
      !go_at(rlimpiador, baseRLimpiador);
	  !hay_papeleraBin(rbasurero, bin);
      .abolish(hay_basura(rlimpiador, trash));
	  .send(rmayordomo, achieve, limpiezaTerminada).


+!hay_papeleraBin(rbasurero, bin) <-
	.send(rbasurero, tell, papelera_llena(rbasurero, bin));
	.wait(100);
	.send(rbasurero, untell, papelera_llena(rbasurero, bin)).


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

+!go_at(rlimpiador,P) : at(rlimpiador,P) <- true.
+!go_at(rlimpiador,P) : not at(rlimpiador,P)
  <- move_towards(P);
     !go_at(rlimpiador,P).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).