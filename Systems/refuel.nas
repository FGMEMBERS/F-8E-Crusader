# By G ROBIN  
# That script must rewriten with feature which ought to be into the FDM (tank management)
# $Id$
# refueling ===========================================================
# we presume a pump capacity of 8 galon_us per second ===== =======



capacity=1348;
#"gal_us "    #Main =513  (tank[0])    #Transfer= 835   (tank[1])
sec_qty=8;

var tank_mainfirst=513;
var tank_transferfirst=835;

var refueling_time=0;
var now_ready=0;
var ref_switch=0;
var now_qty=0;
var orig_qty_tk0=0;
var orig_qty_tk1=0;
var new_qty=0;
var probe_ready = 0;
var pump_ready=0;
var ref_alarm=30;

setprop("/instrumentation/annunciator/refuel-overload",0);
setprop("consumables/fuel/transfer/level-gal_us",0);
setprop("instrumentation/annunciator/refuel-pump",0);

var calculate_filling= func{
        now_ready  = getprop("sim/time/elapsed-sec");
        orig_qty_tk0=getprop("consumables/fuel/tank/level-gal_us");
        orig_qty_tk1=getprop("consumables/fuel/tank[1]/level-gal_us");
        now_qty = orig_qty_tk0+orig_qty_tk1;
        print("new =",new_qty," tk1 =",orig_qty_tk1," tk0 =",orig_qty_tk0);
        req_qty = capacity - now_qty;	
        refueling_time = req_qty / sec_qty;
        print(refueling_time);
}

refuel_air=func {
        probe_ready= getprop("/surface-positions/refueling-pos-norm");
        if (ref_switch==1 and probe_ready==1) {
        not_filled();
        }
        elsif(getprop("/position/altitude-agl-ft")>7 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")>200){
                if (probe_ready == 0) {	
                setprop("/controls/flight/probe-refuel",1);
                ref_switch=1;
                }
        refuel_contact();
        }
        else{
        print("refuel prohibited");
        refuel_prohibited();
        }
}

var refuel_contact=func {
                probe_ready= getprop("/surface-positions/refueling-pos-norm");
                if (probe_ready == 1 and getprop("/systems/refuel/contact") ==1) {
                    setprop("instrumentation/annunciator/refuel-pump",1);
                    print (probe_ready);
                    calculate_filling();
                    ref_switch=1;	
                    full_up();
		}else{
		settimer (refuel_contact,1);
		}
}

refuel_ground=func {
        pump_ready = getprop("instrumentation/annunciator/refuel-pump");
        if (ref_switch==1 and pump_ready==1) {
        not_filled();
        }
        elsif(getprop("/position/altitude-agl-ft")<7 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt")<20){
                  if (pump_ready == 0) {
                  setprop("instrumentation/annunciator/refuel-pump",1);
                  setprop ("/surface-positions/refueling-pos-norm",0);
                  }
                  if (pump_ready == 1){
                      calculate_filling();
                      var text1_refueling = "Refueling on Ground";
                      var text2_refueling =  "Time = " ~ refueling_time;
                          var window = screen.window.new(nil, -100, 3, refueling_time);
                          window.write("");
                          window.write(text1_refueling);
                          window.write(text2_refueling);
                      ref_switch=1;	
                      full_up();	
                  }else{
                  settimer (refuel_ground,1);
                  }
        }
        else{
        print("refuel prohibited");
        refuel_prohibited();
        }
}

var full_up=func {
        if (ref_switch == 1)  {
                now  = getprop("sim/time/elapsed-sec");
                if (now - now_ready > refueling_time ) {
                filled();
                } else {
                durat_time = now - now_ready;
                fill_qty = sec_qty * durat_time;
                new_qty = now_qty + fill_qty;
                if (new_qty-orig_qty_tk0>=tank_transferfirst){
                setprop("consumables/fuel/tank[1]/level-gal_us",tank_transferfirst);
                setprop("consumables/fuel/tank[0]/level-gal_us",new_qty-tank_transferfirst);
                }else{
                setprop("consumables/fuel/tank[1]/level-gal_us",new_qty-orig_qty_tk0);
                }			
                if (new_qty > capacity-ref_alarm){
                setprop("/instrumentation/annunciator/refuel-overload",1);
                }
                settimer (full_up,1);
                }
        } 
}

var filled=func {
		setprop("consumables/fuel/tank/level-gal_us",tank_mainfirst);
		setprop("consumables/fuel/tank[1]/level-gal_us",tank_transferfirst);
                setprop("/controls/flight/probe-refuel",0);
		setprop("/instrumentation/annunciator/refuel-overload",0);
		setprop("consumables/fuel/transfer/level-gal_us",0);
		setprop("instrumentation/annunciator/refuel-pump",0);
                ref_switch = 0 ;
		print ("Filled up");
                var text_filled = "Filled_UP    Good Flight";
                        var window = screen.window.new(nil, -100, 4, 10);
                        window.write("");
                        window.write("");
                        window.write("");
                        window.write(text_filled);
}

var not_filled=func {
		setprop("consumables/fuel/transfer/level-gal_us",0);
		setprop("/instrumentation/annunciator/refuel-overload",0);
		setprop("instrumentation/annunciator/refuel-pump",0);
                setprop("/controls/flight/probe-refuel",0);
                ref_switch = 0 ;
                refueling_time = 0 ;
		print ("Not filled up, your new capacity is:  ", new_qty );
                var text_nofilled = "Not Filled_UP , check your Tank level";
                        var window = screen.window.new(nil, -100, 4, 30);
                        window.write("");
                        window.write("");
                        window.write("");
                        window.write(text_nofilled);
}

var refuel_prohibited=func { 
                print("refuel prohibited");
                var text_prohib = "Sorry operation prohibited";
                      var window = screen.window.new(nil, -100, 4, 10);
                      window.write("");
                      window.write("");
                      window.write("");
                      window.write(text_prohib);
}

var delete_f=func {
		print ("operation aborted");
}







#===============================================================