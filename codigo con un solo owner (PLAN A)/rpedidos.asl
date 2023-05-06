
+delivered(T, Qtd, OrderId, S, M)[source(rmayordomo)]
   <- .println("El robot de pedidos se dirige a la zona de entrega");
      !go_at(rpedidos, delivery);
      .concat("La orden es de: ", Qtd, " de ", T, Ms);
	   .send(S, tell, msg(Ms));
      .abolish(money(_));
      getDelivery(T, Qtd, M);
      .println("El robot de pedidos se dirige al frigorifico");
      !go_at(rpedidos, fridge);
      ?beer(N);
      reponer(T, N);
      .send(rmayordomo, tell, available(T,fridge));
      !go_at(rpedidos, baseRPedidos).


+!go_at(rpedidos,P) : at(rpedidos,P) <- true.
+!go_at(rpedidos,P) : not at(rpedidos,P)
  <- move_towards(P);
     !go_at(rpedidos,P).
    

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).