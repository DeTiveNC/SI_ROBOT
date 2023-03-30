import jason.NoValueException;
import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.Location;
import java.util.logging.Logger;

public class HouseEnv extends Environment {
 
    // common literals

    // Acción de abrir la nevera
    public static final Literal openFridge  = Literal.parseLiteral("open(fridge)");

    // Acción de cerrar la nevera
    public static final Literal closeFridge = Literal.parseLiteral("close(fridge)");

    // Acción de coger una cerveza
    public static final Literal getBeer  = Literal.parseLiteral("get(beer)");
    
    // Acción de entregar una cerveza
    public static final Literal handInBeer  = Literal.parseLiteral("hand_in(beer)");

    // Acción de sorber la cerveza
    public static final Literal sipBeer  = Literal.parseLiteral("sip(beer)");

    // Acción de vaciar el cubo de basura
    public static final Literal vaciarBin  = Literal.parseLiteral("vaciar(bin)");

    // Acción de tirar una lata en el entorno
    public static final Literal generateTrash = Literal.parseLiteral("generateTrash(can)");

    // Acción de recoger una lata del entorno
    public static final Literal pickTrash = Literal.parseLiteral("pickTrash(rlimpiador,trash)");

    // Acciones de tirar la basura el el cubo
    public static final Literal desecharRLimpiadorTrash = Literal.parseLiteral("desechar(rlimpiador,trash)");
    public static final Literal desecharOwnerTrash = Literal.parseLiteral("desechar(owner,trash)");


    // Percepciones de tener cerveza
    public static final Literal hasOwnerBeer = Literal.parseLiteral("has(owner,beer)");

    // Creencias "at" para el agente mayordomo
    public static final Literal atRMayordomoFridge = Literal.parseLiteral("at(rmayordomo,fridge)");
    public static final Literal atRMayordomoCouch = Literal.parseLiteral("at(rmayordomo,couch)");
    public static final Literal atRMayordomoBase = Literal.parseLiteral("at(rmayordomo,baseRMayordomo)");
    
    // Creencias "at" para el agente limpiador
    public static final Literal atRLimpiadorBin = Literal.parseLiteral("at(rlimpiador,bin)");
    public static final Literal atRLimpiadorTrash = Literal.parseLiteral("at(rlimpiador,trash)");
    public static final Literal atRLimpiadorBase = Literal.parseLiteral("at(rlimpiador,baseRLimpiador)");

    // Creencias "at" para el agente basurero
    public static final Literal atRBasureroBin = Literal.parseLiteral("at(rbasurero,bin)");
	public static final Literal atRBasureroBase = Literal.parseLiteral("at(rbasurero,baseRBasurero)");

    // Creencias "at" para el agente pedidos
    public static final Literal atRPedidosDelivery = Literal.parseLiteral("at(rpedidos,delivery)");
    public static final Literal atRPedidosFridge = Literal.parseLiteral("at(rpedidos,fridge)");
    public static final Literal atRPedidosBase = Literal.parseLiteral("at(rpedidos,baseRPedidos)");

    // Creencias "at" para el agente owner
    public static final Literal atOwnerBin = Literal.parseLiteral("at(owner,bin)");
    public static final Literal atOwnerCouch = Literal.parseLiteral("at(owner,couch)");
    public static final Literal atOwnerFridge = Literal.parseLiteral("at(owner,fridge)");


    static Logger logger = Logger.getLogger(HouseEnv.class.getName());

    HouseModel model; // the model of the grid

    @Override
    public void init(String[] args) {
        model = new HouseModel();

        if (args.length == 1 && args[0].equals("gui")) {
            HouseView view  = new HouseView(model);
            model.setView(view);
        }

        updatePercepts();
    }

    /** creates the agents percepts based on the HouseModel */
    void updatePercepts() {

        // Limpieza de creencias de todos los agentes
        clearPercepts("rmayordomo");
        clearPercepts("rlimpiador");
        clearPercepts("rbasurero");
        clearPercepts("rpedidos");
        clearPercepts("owner");

        // Obtención de las posiciones de todos los agentes
        Location lRMayordomo = model.getAgPos(model.agents.get("rmayordomo"));
        Location lRLimpiador = model.getAgPos(model.agents.get("rlimpiador"));
        Location lRBasurero = model.getAgPos(model.agents.get("rbasurero"));
        Location lRPedidos = model.getAgPos(model.agents.get("rpedidos"));
        Location lOwner = model.getAgPos(model.agents.get("owner"));

        // Percepciones de posición del agente rmayordomo
        if (model.lFridgePositions.contains(lRMayordomo)) {
            addPercept("rmayordomo", atRMayordomoFridge);
        }
        else if (model.lCouchPositions.contains(lRMayordomo)) {
            addPercept("rmayordomo", atRMayordomoCouch);
        }
        else if(model.lRMayordomo.equals(lRMayordomo)){
            addPercept("rmayordomo", atRMayordomoBase);
        }

        // Percepciones de posición del agente rlimpiador
        if (model.lBinPositions.contains(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorBin);
        }
        else if(!model.lTrash.isEmpty() && model.lTrash.get(0).equals(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorTrash);
        }
        else if(model.lRLimpiador.equals(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorBase);
        }

        // Percepciones de posición del agente robot rbasurero
        if (model.lBinPositions.contains(lRBasurero)){
            addPercept("rbasurero", atRBasureroBin);
        } else if(model.lRBasurero.equals(lRBasurero)){
            addPercept("rbasurero", atRBasureroBase);
        }

        // Percepciones de posición del agente rpedidos
        if (model.lDeliveryPositions.contains(lRPedidos)){
            addPercept("rpedidos", atRPedidosDelivery);
        }
        else if (model.lFridgePositions.contains(lRPedidos)) {
            addPercept("rpedidos", atRPedidosFridge);
        }
        else if(model.lRPedidos.equals(lRPedidos)){
            addPercept("rpedidos", atRPedidosBase);
        }

        // Percepciones de posición del agente owner
        if (model.lBinPositions.contains(lOwner)){
            addPercept("owner", atOwnerBin);
        }
        else if(model.lCouch.equals(lOwner)){
            addPercept("owner", atOwnerCouch);
        }
        else if(model.lFridgePositions.contains(lOwner)){
            addPercept("owner", atOwnerFridge);
        }

        // Percepción de stock de cervezas para el agente mayordomo
        if (model.fridgeOpenMayordomo) {
            addPercept("rmayordomo", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }

        // Percepción de cervezas en robot de pedidos
        if(model.rpedidosBeers > 0){
            addPercept("rpedidos", Literal.parseLiteral("beer("+model.rpedidosBeers+")"));
        }

        // Percepción de basura en el entorno para el agente mayordomo
        if(model.lTrash.size() > 0){
            addPercept("rmayordomo", Literal.parseLiteral("trashInEnv("+model.lTrash.size()+")"));
            addPercept("rlimpiador", Literal.parseLiteral("trashInEnv("+model.lTrash.size()+")"));
        }

        // Percepción de stock de cervezas para el agente owner
        if (model.fridgeOpenOwner) {
            addPercept("owner", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }

        // Percepciones de que el owner tiene cerveza para los agentes mayordomo y owner
        if (model.sipCount > 0) {
            addPercept("rmayordomo", hasOwnerBeer);
            addPercept("owner", hasOwnerBeer);
        }
    }


    @Override
    public boolean executeAction(String ag, Structure action) {
        System.out.println("["+ag+"] doing: "+action);
        boolean result = false;

        // Acciones de movimiento
        if (action.getFunctor().equals("move_towards")){
            String l = action.getTerm(0).toString();
            Location dest = null;

            // Acciones de movimiento para el robot mayordomo
            if(ag.equals("rmayordomo")){
                if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if (l.equals("couch")) {
                    dest = model.lCouch;
                } else if(l.equals("baseRMayordomo")){
                    dest = model.lRMayordomo;
                }
            }

            // Acciones de movimiento para el robot limpiador
            else if(ag.equals("rlimpiador")){
                if(l.equals("bin")){
                    dest = model.lBin;
                } else if(l.equals("trash")){
                    dest = model.lTrash.get(0);
                } else if(l.equals("baseRLimpiador")){
                    dest = model.lRLimpiador;
                }
            }

            // Acciones de movimiento para el robot basurero
            else if(ag.equals("rbasurero")){
                if(l.equals("bin")){
                    dest = model.lBin;
                } else if(l.equals("baseRBasurero")){
                    dest = model.lRBasurero;
                }
            }

            // Acciones de movimiento para el robot de pedidos
            else if(ag.equals("rpedidos")){
                if (l.equals("delivery")){
                    dest = model.lDelivery;
                } else if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if(l.equals("baseRPedidos")){
                    dest = model.lRPedidos;
                }
            }

            // Acciones de movimiento para el owner
            else if(ag.equals("owner")){
                if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if (l.equals("couch")) {
                    dest = model.lCouch;
                } else if(l.equals("bin")){
                    dest = model.lBin;
                }
            }

            try {
                result = model.moveTowards(ag, dest);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        // Acción de abrir el frigorifico
        else if (action.equals(openFridge) 
            && (ag.equals("rmayordomo") || ag.equals("owner"))) {
            result = model.openFridge(ag);
        } 
        
        // Acción de cerrar el frigorifico
        else if (action.equals(closeFridge) 
            && (ag.equals("rmayordomo")|| ag.equals("owner"))) {
            result = model.closeFridge(ag);

        }

        // Acción de coger una cerveza
        else if (action.equals(getBeer) 
            && (ag.equals("rmayordomo") || ag.equals("owner"))) {
                result = model.getBeer(ag);
        }
        
        // Acción de entregar una cerveza
        else if (action.equals(handInBeer)
            && (ag.equals("rmayordomo") || ag.equals("owner"))) {
            result = model.handInBeer(ag);
        } 
        
        // Acción de sorber la cerveza
        else if (action.equals(sipBeer) && ag.equals("owner")) {
            result = model.sipBeer();
        }

        // Acción de tirar basura en el entorno
        else if(action.equals(generateTrash) && ag.equals("owner")){
            result = model.generateTrash();
        }
        
        // Acción de recoger basura del entorno
        else if(action.equals(pickTrash) 
            && (ag.equals("rlimpiador") || ag.equals("owner"))){
			result = model.pickTrash();	
		}
        
        // Acción de tiral la basura al cubo
        else if
        (
            (action.equals(desecharRLimpiadorTrash) && ag.equals("rlimpiador")) || 
            (action.equals(desecharOwnerTrash) && ag.equals("owner"))
        ){
            result = model.desechar();	
        }

        // Acción de vaciar el cubo de basura
        else if(action.equals(vaciarBin) && ag.equals("rbasurero")){
            result = model.vaciarPapelera();
        }

        // Acción de proveer cerveza
        else if (action.getFunctor().equals("deliver") && ag.contains("supermarket")) {
            // wait 4 seconds to finish "deliver"
            try {
                Thread.sleep(4000);
                result = model.addBeerDelivery((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (Exception e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Acción de coger cerveza del punto de recogida
        else if(action.getFunctor().equals("getDelivery") && ag.equals("rpedidos")){
            try {
                result = model.getDelivery((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (NoValueException e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Acción de reponer las cervezas de la nevera
        else if(action.getFunctor().equals("reponer") && ag.equals("rpedidos")){
            try {
                result = model.addBeerFridge((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (NoValueException e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Error en la realización de alguna acción
        else {
            logger.info("Failed to execute action "+action);
        }

        if (result) {
            updatePercepts();
            try {
                Thread.sleep(100);
            } catch (Exception e) {}
        }
        return result;
    }
}