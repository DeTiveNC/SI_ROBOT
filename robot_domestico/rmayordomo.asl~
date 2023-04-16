/* Initial beliefs and rules */

// Creencia inicial de que hay cerveza disponible
available(beer,fridge).

// Limite de cerveza que puede beber el owner
limit(beer,5).
precioCerveza(50).              
	

// Basura que posee el robot
trash(can, 0). // Ya no es necesario

// Número de cervezas que se piden a la vez
nbeersPerTime(3).

// Calculo para determinar si el owner puede tomar más cerveza
too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB >= Limit.

!bring(owner, beer).
!pide_lista_productos_super.

/* Plans */

+money(Cant)[source(owner)] <- -+money(Cant);	 .send(owner, achieve, restarDinero).

// Esto es mejorable (Se queda parado mientras no se recoge la basura)
+!bring(owner,beer)[source(self)]
   :  trashInEnv(T) & T>0 & not entornoLimpio & cerveza_escogida(M) 
   <- .println("El robot mayordomo revisa si hay basura");
      +entornoLimpio;
      .send(rlimpiador, tell, hay_basura(rlimpiador, trash, plato));
      !bring(owner, beer).

+!bring(owner,beer) [source(self)]
   :  too_much(beer) & limit(beer,L)
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(owner,tell,msg(M));
      .send(owner, tell, ~couldDrink(beer));
      !go_at(rmayordomo, baseRMayordomo);
      .println("El Robot mayordomo descansa porque Owner ha bebido mucho hoy.");
      .wait(10000);
      !bring(owner, beer).

+!bring(owner,beer)[source(self)] 
   :  available(beer,fridge) & not too_much(beer) & asked(beer) & cerveza_escogida(M) 
   <- .println("El robot mayordomo va a buscar una cerveza");
      !go_at(rmayordomo,fridge);
      open(fridge);
      get(beer, pinchito);
	  !comprar(supermarket, beer, M);
      close(fridge);
      !go_at(rmayordomo,couch);
	  .wait(1000);
      !hasBeer(owner);
      .abolish(asked(beer));
      !bring(owner, beer).
	  



+!hasBeer(owner) // : not too_much(beer)
<- hand_in(beer);
   .println("El robot mayordomo pregunta al owner si ha cogido la cerveza y un pincho");
   ?has(owner,beer);
   .println("El Owner tiene la cerveza y pincho.");
   // remember that another beer has been consumed
   .date(YY,MM,DD); .time(HH,NN,SS);
   +consumed(YY,MM,DD,HH,NN,SS,beer).
   

+!bring(owner,beer) [source(self)]
   :  not available(beer,fridge) & not ordered(beer) & cerverza_escogida(M)
   <- .println("El robot mayordomo realiza un pedido de ", M);
      !comprar(supermarket, beer, M);
      !bring(owner, beer).



+!bring(owner, beer): cerveza_escogida(M)
   <- !go_at(rmayordomo, baseRMayordomo);
      .wait(2000);
	   .println("El robot mayordomo está esperando.");
	   !bring(owner, beer).
	   
+!bring(owner,beer)[source(self)]
   <- .println("El robot mayordomo espera a que owner elija cerveza");
   	  .wait(100);
      !bring(owner, beer).

/*
-!bring(K,V)
   :  true
   <- .current_intention(I);
      .print("Failed to achieve goal '!has(K,V)'. Current intention is: ",I);
	  .print(K);
	  .print(V).
	*/ 
+!pide_lista_productos_super 
	<-

	.send(supermarket1, achieve, lista_productos(beer));
	.send(supermarket2, achieve, lista_productos(beer)).

+!lista_productos(beer): seleccion_productos(L1)[source(supermarket1)] & seleccion_productos(L2)[source(supermarket2)] <-

	.concat(L1,L2,L3);
	.print(L3);
	.wait(10);
	.send(owner, tell, seleccionProductos(beer,L3)).
	
+!lista_productos(beer): true
	<- .print("Aun no llegaron los productos");
		.wait(100);
		!lista_productos(beer).
	


+!comprar(supermarket, beer, M) : not ordered(beer)
   <- 
   	  /*.member(M, L3);
   	  .findall(q(Z, X), price(beer, Z, M)[source(X)], L);
      .min(L, Min);
	   !despieza(Min, Z, Agt);
	   .print("El precio menor es ", Z);
	   */
	   .random(X);
      ?nbeersPerTime(NBeer);
	  if(X < 0.3){
	   .send(supermarket1, achieve, order(beer,NBeer, M));
	   }
	   if(X > 0.3){
	   	.send(supermarket2, achieve, order(beer,NBeer, M));
	   }
      .println("El robot mayordomo ha realizado un pedido al supermercado.");
      +ordered(beer).
	  
+!comprar(supermarket, beer, M).

+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

+!limpiezaTerminada <- -entornoLimpio.


+!go_at(rmayordomo,P) : at(rmayordomo,P) <- true.
+!go_at(rmayordomo,P) : not at(rmayordomo,P)
  <- move_towards(P);
     !go_at(rmayordomo,P).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,Qtd,OrderId, N)[source(S)]
  <-  ?money(M)[source(self)];
      ?price(beer, P, N);
      -+money(M-P*Qtd);
      .send(rpedidos, tell, money(P*Qtd));
      .send(rpedidos, tell, delivered(beer, Qtd, OrderId, S, N)).
  
+available(beer, fridge)[source(rpedidos)]
   <- -ordered(beer).

+not_enough_stock(Product, Qtd, Stock)[source(supermarket)] : true
   <- .concat("The supermarket told me they don't have enouth ", Product, 
         "to fullfill my order. (Orderer: ", Qtd, ", Stock: ", Stock, ")", M);
      .send(owner, tell, msg(M)).

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).

+?time(T) : true
  <-  time.check(T). 

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
+hola[source(owner)] <- .print("Hola, te cuento un chiste?"); .send(rmayordomo, tell, chiste).
+contarChiste[source(owner)] <- .print("Con evidentes señales de enfado, la maestra pregunta: Jaimito, ¿te has copiado de Pedro en el examen? Con cara de inocente, Jaimito responde: No, maestra. Entonces, ¿por qué en la respuesta de la pregunta 3, donde Pedro ha puesto no lo sé, has escrito yo tampoco").
