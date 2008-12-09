# By G ROBIN  , 

type = getprop("sim/aircraft");
print ("type: " , type);




#wings flaps, ledroop flaps, pour commande groupée  avec Incidence des ailes done in FDM   JSBSim => wings.xml
#SpeedBrake Now FDM  JSBSim =>speedbrake.xml
#Commande Incidence 2 positions des ailes Now FDM  JSBSim =>wings.xml
#Wing Fold done in FDM   JSBSim => wings.xml
#Agl-Min Announciator Sous FDM =>instruments.xml
#LaunchBar Sous FDM launchbar-hook.xml
#Alimentation Electrique======== Sous FDM
#Control des eclairages Sous FDM => light-outdoor.xml
#Cutoff géré globalement par =jsbsim/fcs/cutoff-switch=voir le FDM => propulsion.xml


Update_engine=func{ 
                var  cutoff0 =0;
                if (getprop("/controls/engines/engine[0]/cutoff-cmd")) { cutoff0 =1; }
                setprop("/controls/engines/engine[0]/cutoff",cutoff0);
        }
#============================================================================================================
#ici on ne peu pas associer une property qui est tratée par JSBSim /fdm/jsbsim/systems/taxi/linked à listener
#on passe donc par une property externe qui est activé /sim/model/taxi/linked
#si l'operation taxi ne peu etre activé pour quelque raisons il faut remettre /sim/model/taxi/linked à Zero
#============================================================================================================
Init_taxi_linked=func{
                if (getprop("/sim/model/taxi/linked") and (getprop("/fdm/jsbsim/systems/taxi/linked") == 0 )){
                setprop("/sim/model/taxi/linked",0);
                }
        }
Loop_update_crusader=func{
        Update_engine();
        Init_taxi_linked();

        settimer ( Loop_update_crusader, 2 );
        }
Loop_update_crusader();



#INIT au démarrage================================================
#INIT OFF TOUT FERMé==============

init_f8e=func{
setprop("/controls/flight/wing-fold-cmd",1);
setprop("/sim/model/mule/linked",1);
setprop("/controls/gear/brake-parking",1);
}



#INIT ON GROUND==============

init_f8eflight=func{
setprop("/controls/electric/master-switch",1);
print("master-switch_true");
setprop("/controls/lighting/landing-lights",1);
setprop("/controls/lighting/instruments-norm",0.15);
setprop("/controls/flight/wing-incidence",1);
setprop("/engines/engine/running",1);
setprop("/controls/flight/canopy",0);
setprop("/fdm/jsbsim/fcs/cutoff-switch",1);
setprop("/controls/flight/wing-fold-cmd",0);
setprop("/controls/gear/brake-parking",1);


#interpolate("/controls/flight/elevator-timer",200,1);
#adjust_elevator();
}


#INIT IN AIR==============
init_f8eair=func{
setprop("/controls/electric/master-switch",1);
print("master-switch_true");
setprop("/controls/lighting/landing-lights",1);
setprop("/controls/lighting/instruments-norm",0.15);
setprop("/controls/flight/wing-incidence",0);
setprop("/engines/engine/running",1);
setprop("/controls/flight/canopy",0);
setprop("/fdm/jsbsim/fcs/cutoff-switch",1);
setprop("/controls/flight/wing-fold-cmd",0);
setprop("/controls/gear/brake-parking",0);
setprop("/controls/gear/gear/gear-down",0);
}

#Only to simulate a landing, FIX ME===========================
	
adjust_elevator=func{
if (getprop("/controls/flight/elevator-timer") > 120){
setprop("/controls/flight/elevator",-0.0);
setprop("/environment/wind-speed-kt",0);
setprop("/controls/engines/engine/throttle",0.35);
}else{
settimer(adjust_elevator,0.1);
}
}

init_carrier=func {
setprop("/ai/models/carrier/controls/glide-path",0);
}

init_carrier();

