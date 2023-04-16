/* Initial beliefs and rules */

// Creencia inicial de que hay cerveza disponible
available(beer,fridge).

// Dinero que posee el robot mayordomo
//money(50).

// Limite de cerveza que puede beber el owner
limit(beer,5).

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

/*
+!bring(myOwner, beer) <-
	+asked(beer).
	
+!bringBeer : healthMsg(_) <- 
	!go_at(myRobot,base);
	.println("El Robot descansa porque Owner ha bebido mucho hoy.").

+!bringBeer : asked(beer) & not healthMsg(_) <- 
	.println("Owner me ha pedido una cerveza.");
	!go_at(myRobot,fridge);
	!take(fridge,beer);
	!go_at(myRobot,myOwner);
	!hasBeer(myOwner);
	.println("Ya he servido la cerveza y elimino la petición.");
	.abolish(asked(Beer));
	!bringBeer.
+!bringBeer : not asked(beer) & not healthMsg(_) <- 
	.wait(2000);
	.println("Robot esperando la petición de Owner.");
	!bringBeer.

+!take(fridge, beer) : not too_much(beer) <-
	.println("El robot está cogiendo una cerveza.");
	!check(fridge, beer).
+!take(fridge,beer) : too_much(beer) & limit(beer, L) <-
	.concat("The Department of Health does not allow me to give you more than ", L," beers a day! I am very sorry about that!", M);
	-+healthMsg(M).
	
+!check(fridge, beer) : not ordered(beer) & available(beer,fridge) <-
	.println("El robot está en el frigorífico y coge una cerveza.");
	.wait(1000);
	open(fridge);
	.println("El robot abre la nevera.");
	get(beer);
	.println("El robot coge una cerveza.");
	close(fridge);
	.println("El robot cierra la nevera.").
+!check(fridge, beer) : not ordered(beer) & not available(beer,fridge) <-
	.println("El robot está en el frigorífico y hace un pedido de cerveza.");
	!orderBeer(mySupermarket);
	!check(fridge, beer).
+!check(fridge, beer) <-
	.println("El robot está esperando ................");
	.wait(5000);
	!check(fridge, beer).
*/

!bring(owner, beer).


/* Plans */

+money(Cant)[source(owner)] <- -+money(Cant);	 .send(owner, tell, restarDinero).

// Esto es mejorable (Se queda parado mientras no se recoge la basura)
+!bring(owner,beer)[source(self)] 
   :  trashInEnv(T) & T>0 & not entornoLimpio
   <- .println("El robot mayordomo revisa si hay basura y platos a recoger");
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
   :  available(beer,fridge) & not too_much(beer) & asked(beer)
   <- .println("El robot mayordomo va a buscar una cerveza y un pincho");
      !go_at(rmayordomo,fridge);
      open(fridge);
      get(beer,pinchito);
	  !comprar(supermarket, beer);
      close(fridge);
      !go_at(rmayordomo,couch);
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

/*
+!hasBeer(myOwner) : too_much(beer) & healthMsg(M) <- 
	//.abolish(msg(_));
	.send(myOwner,tell,msg(M)).
*/

/*
+!bring(owner,beer) [source(self)]
   :  not available(beer,fridge) & not ordered(beer)
   <- .println("El robot mayordomo realiza un pedido");
      !comprar(supermarket, beer);
      !bring(owner, beer).
*/
+!bring(owner, beer)
   <- !go_at(rmayordomo, baseRMayordomo);
      .wait(2000);
	   .println("El robot mayordomo está esperando.");
	   !bring(owner, beer).


-!bring(_,_)
   :  true
   <- .current_intention(I);
      .print("Failed to achieve goal '!has(_,_)'. Current intention is: ",I).

+!comprar(supermarket, beer) : not ordered(beer)
   <- .findall(q(Z, X), price(beer, Z)[source(X)], L);
      .min(L, Min);
	   !despieza(Min, Z, Agt);
	   .print("El precio menor es ", Z);
      ?nbeersPerTime(NBeer);
	   .send(Agt, achieve, order(beer,NBeer));
      .println("El robot mayordomo ha realizado un pedido al supermercado.");
      +ordered(beer).
+!comprar(supermarket, beer).

+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

+!limpiezaTerminada <- -entornoLimpio.



+!go_at(rmayordomo,P) : at(rmayordomo,P) <- true.
+!go_at(rmayordomo,P) : not at(rmayordomo,P)
  <- move_towards(P);
     !go_at(rmayordomo,P).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,Qtd,OrderId)[source(S)]
  <-  ?money(M)[source(self)];
      ?price(beer, P)[source(S)];
      -+money(M-P*Qtd);
      .send(rpedidos, tell, money(P*Qtd));
      .send(rpedidos, tell, delivered(beer, Qtd, OrderId, S)).
  
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
