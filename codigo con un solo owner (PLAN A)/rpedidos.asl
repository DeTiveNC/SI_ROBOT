
+delivered(beer,pinchito, Qtd, OrderId, S, M, T, Cant)[source(rmayordomo)]
   <- .println("El robot de pedidos se dirige a la zona de entrega");
      !go_at(rpedidos, delivery);
      .concat("La orden es de: ", Qtd+Cant, " beer y pinchito.", Ms);
	   .send(S, tell, msg(Ms));
      .abolish(money(_));
      getDelivery(beer, Qtd+Cant, M);
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