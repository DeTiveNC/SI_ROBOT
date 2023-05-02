
+delivered(beer,Cantidad, OrderId, S, M)[source(rmayordomo)]
   <- .println("El robot de pedidos se dirige a la zona de entrega");
      !go_at(rpedidos, delivery);
      .concat("the order has been delivered: ", Cantidad, " beers.", Ms);
	   .send(S, tell, msg(Ms));
      .abolish(money(_));
      getDelivery(beer, Cantidad, M);
      .println("El robot de pedidos se dirige al frigorifico");
      !go_at(rpedidos, fridge);
      ?beer(N);
      reponer(beer, N);
      .send(rmayordomo, tell, available(beer,fridge));
      !go_at(rpedidos, baseRPedidos).


+!go_at(rpedidos,P) : at(rpedidos,P) <- true.
+!go_at(rpedidos,P) : not at(rpedidos,P)
  <- move_towards(P);
     !go_at(rpedidos,P).
    

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).