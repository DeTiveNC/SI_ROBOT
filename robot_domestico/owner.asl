trash(can,0).
money(500).

/* Initial goals */

!drink(owner, beer).
// !get(beer).   // initial goal: get a beer
!check_bored. // initial goal: verify whether I am getting bored

+!get(beer) : not asked(beer)
   <-  
   	  .send(rmayordomo, tell, asked(beer));
       Y = 50;
   	  .send(rmayordomo, tell, money(Y)); 	   	
      .println("Owner ha pedido una cerveza al robot mayordomo.");
      +asked(beer).

+restarDinero <- 
	   ?money(A);
	   -money(A);
       X = A - 50;
      +money(X).
+!drink(owner, beer) : not has(owner, beer) & not asked(beer)
   <- .println("Owner no tiene cerveza.");
      .random(X);
      !get(beer);
      /*
      Comentado para probar los robots
      if(X>0.7){
         !cogerCerveza(owner, beer);
      } else{
         !get(beer);
      }
      */
      
      !drink(owner, beer).

+!drink(owner, beer) : has(owner, beer)
   <- .println("Owner ya tiene una cerveza y se dispone a beberla.");
      !sip(beer);
      ?trash(can,C);
      -+trash(can, C+1);
	  .random(X);
      !lanzar(can);
      /*
      Comentado para probar los robots
      if(X < 0.33){
         !lanzar(can);
      }elif(X < 0.66){
         !darBasuraRobot(can);   
      } else{
         !tirarLata(owner, can);
      }
      */
      
      !drink(owner, beer).

+!drink(owner, beer) : ~couldDrink(beer)
   <- .println("Owner ha bebido demasiado por hoy.").	

+!drink(owner, beer) : not has(owner,beer) & asked(beer)
   <- .println("Owner está esperando una cerveza.");
	   .wait(500);
	   !drink(owner, beer).
/*
+!cogerCerveza(owner, beer) : true
   <- .println("Owner va a coger una cerveza.");
      !go_at(owner, fridge);
      open(fridge);
      !get(owner, beer).
*/
/*
+!getBeer(owner, beer) : available(beer,fridge)
   <- .println("Owner coge una cerveza");
      get(beer);
      close(fridge);
      !go_at(owner,couch);
      hand_in(beer).
+!getBeer(owner, beer) : not available(beer,fridge)
   <- .println("Owner se encuentra la nevera vacía");
      .send(rmayordomo, untell, available(beer,fridge));
      !go_at(owner, couch).
*/
/*
+!tirarLata(owner, can) : trash(can, C) & C>0
   <- .println("Owner va a tirar una lata a la basura.");
      !go_at(owner,bin);
      desechar(owner, trash);
      -+trash(can, C-1);
      !go_at(owner,couch).
+!tirarLata(owner, can).   
*/
+!lanzar(Elem) : trash(can, C) & C>0
   <- .println("Owner va a lanzar una lata.");
      generateTrash(Elem);
      -+trash(Elem, C-1).
+!lanzar(Elem).


+!darBasuraRobot(Elem) : trash(can, C) & C>0
   <- .println("Owner le entrega basura al robot mayordomo.");
      .send(rmayordomo, achieve, recogerBasuraOwner(Elem, C));
      -+trash(Elem, 0).

+!sip(beer) : not has(owner,beer)
   <- true.
+!sip(beer): has(owner,beer) & asked(beer)
   <- .println("Owner va a empezar a beber cerveza.");
      -asked(beer);
      sip(beer);
      !sip(beer).
+!sip(beer): has(owner,beer) & not asked(beer)
   <- sip(beer);
      .println("Owner está bebiendo cerveza.");
      !sip(beer).

/*
+!check_bored: trashInEnv(T) & T > 0
	<- !go_at(owner, trash);
      pickTrash(owner, trash);
      !check_bored.
*/

+!check_bored : true
   <- .random(X); .wait(X*5000+2000);   // i get bored at random times
   	  .random(Y);
	  if( Y < 0.5){
      .send(rmayordomo, askOne, time(_), R); // when bored, I ask the robot about the time
      .print(R);
	  } else {
	  	.send(rmayordomo, tell, hola);
		
	  }
      !check_bored.

+!go_at(owner,P) : at(owner,P) <- true.
+!go_at(owner,P) : not at(owner,P)
  <- move_towards(P);
     !go_at(owner,P).

+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).


+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
+chiste[(source(rmayordomo))] <- .print("Si"); .send("Con evidentes señales de enfado, la maestra pregunta: Jaimito, ¿te has copiado de Pedro en el examen? Con cara de inocente, Jaimito responde: No, maestra. Entonces, ¿por qué en la respuesta de la pregunta 3, donde Pedro ha puesto no lo sé, has escrito yo tampoco").
