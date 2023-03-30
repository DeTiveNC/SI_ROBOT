/* Initial beliefs and rules */

// initially, I believe that there is some beer in the fridge
available(beer,fridge).

money(50).

// my owner should not consume more than 10 beers a day :-)
limit(beer,5).
trash(can, 0).
nbeersPerTime(3).

allowed(self).
allowed(owner).

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

+!orderBeer(Supermarket) : not ordered(beer) <-
	.println("El robot ha realizado un pedido al supermercado.");
	!go_at(myRobot,delivery);
	.println("El robot va a la ZONA de ENTREGA.");
	.send(Supermarket, achieve, order(beer,3));
	+ordered(beer).
+!orderBeer(Supermarket).

+!hasBeer(myOwner) : not too_much(beer) <-
	hand_in(beer);
	.println("He preguntado si Owner ha cogido la cerveza.");
	?has(myOwner,beer);
	.println("Se que Owner tiene la cerveza.");
	// remember that another beer has been consumed
	.date(YY,MM,DD); .time(HH,NN,SS);
	+consumed(YY,MM,DD,HH,NN,SS,beer).
+!hasBeer(myOwner) : too_much(beer) & healthMsg(M) <- 
	//.abolish(msg(_));
	.send(myOwner,tell,msg(M)).

*/

!bring(owner, beer).

+not_enough_stock(Product, Qtd, Stock)[source(supermarket)] : true
   <- .concat("The supermarket told me they don't have enouth ", Product, 
         "to fullfill my order. (Orderer: ", Qtd, ", Stock: ", Stock, ")", M);
      .send(owner, tell, msg(M)).

/* Plans */

+!bring(owner,beer) [source(A)]
   :  allowed(A) & too_much(beer) & limit(beer,L)
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(owner,tell,msg(M));
      .send(owner, achieve, notCouldDrink(beer));
      // !go_at(robot, base); por programar
      .println("El Robot descansa porque Owner ha bebido mucho hoy.").


+!bring(owner,beer)[source(A)] 
   :  allowed(A) & available(beer,fridge) & not too_much(beer) & asked(beer)
   <- .println("El robot va a buscar una cerveza");
      !go_at(robot,fridge);
      open(fridge);
      !get(robot, beer);
      !bring(owner, beer).

+!get(robot, beer) : available(beer, fridge)
   <- get(beer);
      close(fridge);
      !go_at(robot,owner);
      hand_in(beer);
      -asked(beer)[source(owner)];
      // ?has(owner,beer); no entiendo para que sirve
      // remember that another beer has been consumed
      .date(YY,MM,DD); .time(HH,NN,SS);
      +consumed(YY,MM,DD,HH,NN,SS,beer).
+!get(robot, beer) : not available(beer, fridge)
   <- .println("No hay cervezas").




+!bring(owner,beer) [source(A)]
   :  allowed(A) & not available(beer,fridge) & not ordered(beer)
   <- .println("El robot va a la zona de entrega a realizar un pedido");
      !go_at(robot, delivery);
      !comprar(supermarket, beer);
      !bring(owner, beer).

+!bring(owner,beer)[source(A)] 
   :  allowed(A) & not asked(beer) &
      ((trashInEnv(T) & T>0) | (trash(can, C) & C>0))
   <- .println("El robot revisa si hay basura");
      !recogerBasura(robot, trash);
      !tirarBasura(robot, bin);
      !bring(owner, beer).


+!bring(owner, beer) : not asked(beer) & not too_much(beer)
   <- //!go_at(robot, base);
      .wait(2000);
	   .println("Robot esperando la petición de Owner.");
	   !bring(owner, beer).


-!bring(_,_)
   :  true
   <- .current_intention(I);
      .print("Failed to achieve goal '!has(_,_)'. Current intention is: ",I).

+!recogerBasura(robot, trash) : trashInEnv(T) & T > 0
   <- !go_at(robot, trash);
      pickTrash(robot, trash);
      ?trash(can, C);
      -+trash(can, C+1);
      !recogerBasura(robot,trash).
+!recogerBasura(robot, trash).

+!tirarBasura(robot, bin): trash(can, X) & X>0
   <- !go_at(robot, bin);
      !desechar(robot, trash).
+!tirarBasura(robot, bin).

+!desechar(robot, trash) : trash(can, X) & X>0
   <- desechar(robot, trash);
      -+trash(can, X-1);
      !desechar(robot, trash).
+!desechar(robot,trash).

+!recogerBasuraOwner(Elem, Cantidad) [source(owner)] : true
   <- ?trash(Elem, C);
      -trash(Elem, C);
      +trash(Elem, C+Cantidad).

+!comprar(supermarket, beer) : not ordered(beer)
   <- .findall(q(Z, X), price(beer, Z)[source(X)], L);
      .min(L, Min);
	   !despieza(Min, Z, Agt);
	   .print("El precio menor es ", Z);
      ?nbeersPerTime(NBeer);
	   .send(Agt, achieve, order(beer,NBeer));
      +ordered(beer).
+!comprar(supermarket, beer).




+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

+!go_at(robot,P) : at(robot,P) <- true.
+!go_at(robot,P) : not at(robot,P)
  <- move_towards(P);
     !go_at(robot,P).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer,Qtd,OrderId)[source(S)]
  <-  !go_at(robot, delivery);
      ?money(M)[source(self)];
      ?price(beer, P)[source(S)];
      -+money(M-P*Qtd);
	   .concat("the order has been delivered: ", Qtd, " beers.", Ms);
	   .send(S, tell, msg(Ms));
      !go_at(robot, fridge);
      +available(beer,fridge);
      !bring(owner,beer).

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

