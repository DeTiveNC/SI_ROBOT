/*Stock de cada cerveza que se enviara a los supermercados */
stock(beer, 50, estrella).
stock(beer, 50, aguila).
stock(beer, 50, volldamm).
stock(beer, 50, redvintage).
stock(beer, 50, heineken).
/*Precios de las cervezas*/
price(beer, 8, aguila).
price(beer, 6, estrella). 
price(beer, 3, volldamm). 
price(beer, 7, heineken). 
price(beer, 10, redvintage).
price(beer, 9, aguila).
price(beer, 4, estrella). 
price(beer, 5, volldamm). 
price(beer, 5, heineken). 
price(beer, 12, redvintage).


+dar_precioystock[source(supermarket1)] : true
	<-	.send(supermarket1, tell, stock(beer, 50, estrella));
		.send(supermarket1, tell, stock(beer, 50, aguila));
		.send(supermarket1, tell, stock(beer, 50, volldamm));
		.send(supermarket1, tell, stock(beer, 50, redvintage));
		.send(supermarket1, tell, stock(beer, 50, heineken));
		.send(supermarket1, tell, price(beer, 8, aguila));
		.send(supermarket1, tell, price(beer, 6, estrella));
		.send(supermarket1, tell, price(beer, 3, volldamm));
		.send(supermarket1, tell, price(beer, 7, heineken));
		.send(supermarket1, tell, price(beer, 10, redvintage));
		.send(supermarket1, achieve, actualizar_moneySuperNeg(50*8+50*6+50*3+50*7+50*10)).
+dar_precioystock[source(supermarket2)] : true
	<-	.send(supermarket2, tell, stock(beer, 50, estrella));
		.send(supermarket2, tell, stock(beer, 50, aguila));
		.send(supermarket2, tell, stock(beer, 50, volldamm));
		.send(supermarket2, tell, stock(beer, 50, redvintage));
		.send(supermarket2, tell, stock(beer, 50, heineken));
		.send(supermarket2, tell, price(beer, 9, aguila));
		.send(supermarket2, tell, price(beer, 4, estrella));
		.send(supermarket2, tell, price(beer, 5, volldamm));
		.send(supermarket2, tell, price(beer, 5, heineken));
		.send(supermarket2, tell, price(beer, 12, redvintage));
		.send(supermarket2, achieve, actualizar_moneySuperNeg(50*9+50*4+50*5+50*5+50*12)).


+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
