last_order_id(1). // initial belief
moneySuper(500).


stock(beer, 11).

!sendPrice.

+!sendPrice : price(beer, P)
  <-  .println("Envío de precio al robot mayordomo");
      .send(rmayordomo, tell, price(beer, P));
	  ?stock(beer, Z);
	  ?moneySuper(B);
	 -moneySuper(B);
	 Y = P*Z;
	 C = B - Y;
	 +moneySuper(C).
+!sendPrice : true
   <- .println("No hay datos sobre precios en este supermercado").

// plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd)[source(Ag)] : stock(Product, P) & P >= Qtd
  <- ?last_order_id(N);
     OrderId = N + 1;
	  ?price(beer, Z);
     -+last_order_id(OrderId); 
     -stock(beer, _);
     +stock(beer, P-Qtd);
     deliver(Product,Qtd);
	 ?moneySuper(A);
	 -moneySuper(A);
	 X = Qtd*Z;
	 +moneySuper(A+X);
     .send(Ag, tell, delivered(Product,Qtd,OrderId)).

+!order(Product,Qtd)[source(Ag)] : stock(Product, P) & P < Qtd
  <- .print("Out of stock: ", Product);
     .send(Ag, tell, not_enough_stock(Product, Qtd, P)).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).