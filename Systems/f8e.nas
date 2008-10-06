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
        
Loop_update_crusader=func{
        Update_engine();
# Refuel();
        settimer ( Loop_update_crusader, 2 );
        }
Loop_update_crusader();

#Only for  JBD , the value "Engaged"  is wanted (would be better with boolean value "true" "false) 

JBD_op=func{
              if(getprop("/fdm/jsbsim/launchbar/launch-bar-state")== 1){
                setprop("/gear/launchbar/state","Engaged");
                # print("Engaged");
                }else{setprop("/gear/launchbar/state","Disengaged");
                }
}
setlistener("/fdm/jsbsim/launchbar/launch-bar-state",JBD_op);



#INIT au démarrage================================================

init_f8e=func{
setprop("/controls/flight/wing-fold-cmd",1);
}


setprop("/controls/flight/elevator-timer",0);

init_f8eflight=func{
setprop("/controls/electric/master-switch",1);
print("master-switch_true");
setprop("/controls/flight/wing-incidence",1);
setprop("/engines/engine/running",1);
setprop("/controls/flight/canopy",0);
setprop("/fdm/jsbsim/fcs/cutoff-switch",1);
setprop("/controls/flight/brake-parking",0);
setprop("/controls/flight/wing-fold",1);


interpolate("/controls/flight/elevator-timer",200,1);

adjust_elevator();
}	
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

