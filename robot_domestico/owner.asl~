trash(can,0).
platoVa(plato, 0).
money(500).

/* Initial goals */

!drink(owner, beer).
!pide_lista_productos.

!check_bored. // initial goal: verify whether I am getting bored

+!get(beer) : not asked(beer)
   <- 
   	  .send(rmayordomo, tell, asked(beer));
      Y = 50;
   	 .send(rmayordomo, tell, money(Y)); 	   	
      .println("Owner ha pedido una cerveza al robot mayordomo.");
      +asked(beer);
	  .wait(200).

	  
	  
+!restarDinero <- 
	.print("Cerveza pagada.");
	?money(M);
       L = M - 50;
      -+money(L).
	  
+!restarDinero(Cant): Cant == 0 <- true.
	  
+!drink(owner, beer) : not has(owner, beer) & not asked(beer)
   <- .println("Owner no tiene cerveza y un pincho.");
      .random(X);
      !get(beer);
 
      !drink(owner, beer).

+!drink(owner, beer) : has(owner, beer)
   <- .println("Owner ya tiene una cerveza y se dispone a beberla.");
      !sip(beer);
      ?trash(can,C);
	  ?platoVa(plato, D);
      -+trash(can, C+1);
	  -+platoVa(plato, D+1);
      !lanzar(can);
	  !recogerplatosucio(plato);
      !drink(owner, beer).

+!drink(owner, beer) : ~couldDrink(beer)
   <- .println("Owner ha bebido demasiado por hoy.").	

+!drink(owner, beer) : not has(owner,beer) & asked(beer)
   <- .println("Owner está esperando una cerveza.");
	   .wait(500);
	   !drink(owner, beer).

+!lanzar(Elem) : trash(can, C) & C>0
   <- .println("Owner va a lanzar una lata.");
      generateTrash(Elem);
      -+trash(Elem, C-1).
+!lanzar(Elem).

+!recogerplatosucio(Elem) : platoVa(plato, D) & D>0
 <-   .println("Owner deja su plato sucio.");
      generatePlato(Elem);
      -+platoVa(Elem, D-1).
+!recogerplatosucio.	  

+!sip(beer) : not has(owner,beer)
   <- true.
+!sip(beer): has(owner,beer) & asked(beer)
   <- .println("Owner va a empezar a beber cerveza y comer un pincho.");
      -asked(beer);
      sip(beer);
      !sip(beer).
+!sip(beer): has(owner,beer) & not asked(beer)
   <- sip(beer);
      .println("Owner está bebiendo cerveza y comiendo un pincho.");
      !sip(beer).


+!pide_lista_productos 
	<-
	.send(rmayordomo, achieve, lista_productos(beer));	
	.wait(100);
	!escoge_productos.

+!escoge_productos: seleccionProductos(beer, L1)[source(rmayordomo)]
	<-
		.random(L1, X);
	   !despieza(X, M, _); // _ = no me interesa valor
	   .print("Cerveza elegida: ", M); 
	   .send(rmayordomo, tell, cerveza_escogida(M)).
	   
	   
+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

+!escoge_productos
	<- .wait(100);
		!escoge_productos.
		
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
+chiste[(source(rmayordomo))] <- .print("Si"); .send(rmayordomo, tell, contarChiste).
