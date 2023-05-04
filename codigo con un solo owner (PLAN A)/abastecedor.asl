/*Stock de cada cerveza que se enviara a los supermercados */
stock(beer, 50, estrella).
stock(beer, 50, aguila).
stock(beer, 50, volldamm).
stock(beer, 50, redvintage).
stock(beer, 50, heineken).



+dar_precioystock[source(supermarket1)] : true
	<-	.send(supermarket1, tell, stock(beer, 50, estrella));
		.send(supermarket1, tell, stock(beer, 50, aguila));
		.send(supermarket1, tell, stock(beer, 50, volldamm));
		.send(supermarket1, tell, stock(beer, 50, redvintage));
		.send(supermarket1, tell, stock(beer, 50, heineken));
		.random(X);
		A = X*10+1;
		.random(Y);
		B = Y*10+1;
		.random(W);
		C = W*10+1;
		.random(Z);
		D = Z*10+1;
		.random(N);
		E = N*10+1;
		.send(supermarket1, tell, price(beer, B, aguila));
		.send(supermarket1, tell, price(beer, C, estrella));
		.send(supermarket1, tell, price(beer, D, volldamm));
		.send(supermarket1, tell, price(beer, A, heineken));
		.send(supermarket1, tell, price(beer, E, redvintage));
		.send(supermarket1, achieve, actualizar_moneySuperNeg(50*A+50*B+50*C+50*D+50*E)).
+dar_precioystock[source(supermarket2)] : true
	<-	.send(supermarket2, tell, stock(beer, 50, estrella));
		.send(supermarket2, tell, stock(beer, 50, aguila));
		.send(supermarket2, tell, stock(beer, 50, volldamm));
		.send(supermarket2, tell, stock(beer, 50, redvintage));
		.send(supermarket2, tell, stock(beer, 50, heineken));
		.random(X);
		A = X*10+1;
		.random(Y);
		B = Y*10+1;
		.random(W);
		C = W*10+1;
		.random(Z);
		D = Z*10+1;
		.random(N);
		E = N*10+1;
		.send(supermarket2, tell, price(beer, B, aguila));
		.send(supermarket2, tell, price(beer, C, estrella));
		.send(supermarket2, tell, price(beer, D, volldamm));
		.send(supermarket2, tell, price(beer, A, heineken));
		.send(supermarket2, tell, price(beer, E, redvintage));
		.send(supermarket2, achieve, actualizar_moneySuperNeg(50*A+50*B+50*C+50*D+50*E)).


+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).

