#Calcul de positionnement du porte-avion ainsi que de ses catapultes respectives ====
#this is a nasal script scratch, anybody who want to improve it , can do it.
#Just REMEMBER, we need to know, on line,every catapults, which are available with the selected Carrier.
#That will be necessary for (coming soon) an automatic positionning (taxiing) of the Aircraft on a choosen catapult.

#2008-11-17 v 0.1
#Copyright (C) 2008  Gerard Robin 
#This file is licensed under the GPL license v2 or later


  initialized = 0;
  enabled = 0;
  var first_contact = 0;
  var clem = "Clemenceau";
  var foch = "Foch";
  var arro = "Arromanches";
  var nimitz = "Nimitz";
  var eisenhower = "Eisenhower";
  var cdg = "Chales_de_Gaulle";

  var max_dist_m = 200;

  var cat1_head = 0;
  var cat1_dist = 0;
  var cat1_heading_rad = 0;
  
  var cat2_head = 0;
  var cat2_dist = 0;
  var cat2_heading_rad = 0;

  var cat3_head = 0;
  var cat3_dist = 0;
  var cat3_heading_rad = 0;

  var cat4_head = 0;
  var cat4_dist = 0;
  var cat4_heading_rad = 0;

  print ("running Carrier_Contact => => =>" );

#=========================================================================
  updateCarrier = func {
    if (initialized  != 1 ) {
    init_contact();}
    var AllCarrier = props.globals.getNode("ai/models").getChildren("carrier");
    var selectedCarrier = [];
      if ( enabled) { 

#==============Are we on ground/deck=======================================

        if (getprop ("gear/gear[1]/wow")){

#==============Now looking for the closest Carrier========================= 
            foreach(m; AllCarrier) {
              var   id_node = m.getNode("id" , 1 );
                var  id = id_node.getValue();
                  if ( id != nil ) {
                    var  contact_node = m.getNode("name");
                    var  contact = contact_node.getValue();
                    var lat_pos_node = m.getNode("position/latitude-deg");
                        lat_pos = lat_pos_node.getValue();
              #print ("lat ",lat_pos);
                    var lon_pos_node = m.getNode("position/longitude-deg");
                      lon_pos = lon_pos_node.getValue();
              #print ("lon ",lon_pos);
                    var heading_node = m.getNode("orientation/true-heading-deg");
                    var heading = heading_node.getValue();
              #print (heading);
                    var aircraft_pos = geo.aircraft_position();
                    var carrier_pos  = geo.Coord.new().set_latlon(lat_pos,lon_pos);

                    if (aircraft_pos.direct_distance_to(carrier_pos) < max_dist_m ){

#============Found one Carrier, Now looking for which Ship class============
#============And loading the corresponding Deck Geometry definition=========

                      if (first_contact == 0) { 

                      setprop ("/sim/carrier/name",contact);
                      print ("WELCOME ON BOARD, CARRIER: => ",contact," <=");
                      first_contact = 1;
                      var text_welcome = "Welcome on board  " ~ contact;
                      var window = screen.window.new(nil, -100, 3, 30);
                      window.write(text_welcome);
                          if ((contact == clem) or (contact == foch)) {
                                cat1_heading_rad = getprop("sim/carrier/clemenceau/catapult1/heading_rad");
                                cat1_head = getprop("sim/carrier/clemenceau/catapult1/coord_course");
                                cat2_heading_rad = getprop("sim/carrier/clemenceau/catapult2/heading_rad");
                                cat2_head = getprop("sim/carrier/clemenceau/catapult2/coord_course");
                                cat3_head = 0;
                                cat4_head = 0;
                                cat1_dist = getprop("sim/carrier/clemenceau/catapult1/coord_dist");
                                cat2_dist = getprop("sim/carrier/clemenceau/catapult2/coord_dist");
                                cat3_dist = 999999;
                                cat4_dist = 999999;
                          }
                          if ((contact == nimitz) or (contact == eisenhower)) {
                                cat1_heading_rad = getprop("sim/carrier/nimitz/catapult1/heading_rad");
                                cat2_heading_rad = getprop("sim/carrier/nimitz/catapult2/heading_rad");
                                cat3_heading_rad = getprop("sim/carrier/nimitz/catapult3/heading_rad");
                                cat4_heading_rad = getprop("sim/carrier/nimitz/catapult4/heading_rad");
                                cat1_head = getprop("sim/carrier/nimitz/catapult1/coord_course");
                                cat2_head = getprop("sim/carrier/nimitz/catapult2/coord_course");
                                cat1_dist = getprop("sim/carrier/nimitz/catapult1/coord_dist");
                                cat2_dist = getprop("sim/carrier/nimitz/catapult2/coord_dist");
                                cat3_head = getprop("sim/carrier/nimitz/catapult3/coord_course");
                                cat4_head = getprop("sim/carrier/nimitz/catapult4/coord_course");
                                cat3_dist = getprop("sim/carrier/nimitz/catapult3/coord_dist");
                                cat4_dist = getprop("sim/carrier/nimitz/catapult4/coord_dist");
                          }
                          if ((contact == arro)) {
                                cat1_heading_rad = getprop("sim/carrier/arromanches/catapult1/heading_rad");
                                cat1_head = getprop("sim/carrier/arromanches/catapult1/coord_course");
                                cat2_head = 0;
                                cat3_head = 0;
                                cat4_head = 0;
                                cat1_dist = getprop("sim/carrier/arromanches/catapult1/coord_dist");
                                cat2_dist = 999999;
                                cat4_dist = 999999;
                                cat3_dist = 999999;
                                cat4_dist = 999999;
                          }
                          if ((contact == cdg)) {
                                cat1_heading_rad = getprop("sim/carrier/charles_de_gaulle/catapult1/heading_rad");
                                cat2_heading_rad = getprop("sim/carrier/charles_de_gaulle/catapult2/heading_rad");
                                cat1_head = getprop("sim/carrier/charles_de_gaulle/catapult1/coord_course");
                                cat2_head = getprop("sim/carrier/charles_de_gaulle/catapult2/coord_course");
                                cat3_head = 0;
                                cat4_head = 0;
                                cat1_dist = getprop("sim/carrier/charles_de_gaulle/catapult1/coord_dist");
                                cat2_dist = getprop("sim/carrier/charles_de_gaulle/catapult2/coord_dist");
                                cat3_dist = 999999;
                                cat4_dist = 999999;
                          }
                      }

#=============A real time update of the positions=====================

                      setprop ("sim/carrier/heading-deg",heading);
                      geo.Coord.set_latlon(lat_pos,lon_pos);
                      var get_coord_lat = geo.Coord.lat();
                      var get_coord_lon = geo.Coord.lon();
              #print ("coord ",get_coord_lat," ",get_coord_lon);

#=============First Catapult=============FIXME catapults should be stored in an indexed array n 1 to 4  ===============

                      var catapult = geo.Coord.new().set_latlon(lat_pos,lon_pos);
                      var Cat1_pos  = catapult.apply_course_distance(cat1_head + heading,cat1_dist);
                      var Cat1_pos_lat = Cat1_pos.lat();
                      var Cat1_pos_lon = Cat1_pos.lon();
                          setprop ("/fdm/jsbsim/systems/carrier/cat1-lat-position",Cat1_pos_lat);
                          setprop ("/fdm/jsbsim/systems/carrier/cat1-lon-position",Cat1_pos_lon);
                          setprop ("/sim/carrier/cat1-heading-rad",cat1_heading_rad);
              #print ("Cat1 lt ",Cat1_pos_lat,"Cat1 ln ",Cat1_pos_lon);

#=============The others optional Catapult============================

                  if (cat2_dist != 999999) {

                      var catapult = geo.Coord.new().set_latlon(lat_pos,lon_pos);
                      var Cat2_pos  = catapult.apply_course_distance(cat2_head + heading,cat2_dist);
                      var Cat2_pos_lat = Cat2_pos.lat();
                      var Cat2_pos_lon = Cat2_pos.lon();
                          setprop ("/fdm/jsbsim/systems/carrier/cat2-lat-position",Cat2_pos_lat);
                          setprop ("/fdm/jsbsim/systems/carrier/cat2-lon-position",Cat2_pos_lon);
                          setprop ("/sim/carrier/cat2-heading-rad",cat2_heading_rad);
              #print ("Cat2 lt ",Cat2_pos_lat,"Cat2 ln ",Cat2_pos_lon);
                  }      
                  if (cat3_dist != 999999) {

                      var catapult = geo.Coord.new().set_latlon(lat_pos,lon_pos);
                      var cat3_pos  = catapult.apply_course_distance(cat3_head + heading,cat3_dist);
                      var cat3_pos_lat = cat3_pos.lat();
                      var cat3_pos_lon = cat3_pos.lon();
                          setprop ("/fdm/jsbsim/systems/carrier/cat3-lat-position",cat3_pos_lat);
                          setprop ("/fdm/jsbsim/systems/carrier/cat3-lon-position",cat3_pos_lon);
                          setprop ("/sim/carrier/cat3-heading-rad",cat3_heading_rad);
              #print ("cat3 lt ",cat3_pos_lat,"cat3 ln ",cat3_pos_lon);
                  }
                  if (cat4_dist != 999999) {

                      var catapult = geo.Coord.new().set_latlon(lat_pos,lon_pos);
                      var cat4_pos  = catapult.apply_course_distance(cat4_head + heading,cat4_dist);
                      var cat4_pos_lat = cat4_pos.lat();
                      var cat4_pos_lon = cat4_pos.lon();
                          setprop ("/fdm/jsbsim/systems/carrier/cat4-lat-position",cat4_pos_lat);
                          setprop ("/fdm/jsbsim/systems/carrier/cat4-lon-position",cat4_pos_lon);
                          setprop ("/sim/carrier/cat4-heading-rad",cat4_heading_rad);
              #print ("cat4 lt ",cat4_pos_lat,"cat4 ln ",cat4_pos_lon);
                  }
  } 
                    } 
                } 
          } else { first_contact = 0; setprop ("/sim/carrier/name","none");}
        }
      settimer(updateCarrier,0.03);
  }
  init_contact = func {
      var  AI_Enabled = props.globals.getNode("sim/ai/enabled");
      enabled = AI_Enabled.getValue();
      initialized = 1;
  }
updateCarrier();


#Only for  JBD , the value "Engaged"  is wanted (would be better with boolean value "true" "false) 

JBD_op=func{
              if(getprop("/fdm/jsbsim/launchbar/launch-bar-state")== 1){
                setprop("/gear/launchbar/state","Engaged");
                # print("Engaged");
                }else{setprop("/gear/launchbar/state","Disengaged");
                }
}
setlistener("/fdm/jsbsim/launchbar/launch-bar-state",JBD_op);

#=========================FIXME catapults should be stored in an indexed array n 1 to 4  ===============


taxi_op=func{
          var taxi_to = getprop("/sim/model/taxi/taxi_to");
           if (getprop("/sim/model/taxi/linked") == 1 and taxi_to != 0){
          if (taxi_to == 1){
              var dest_lat = getprop("/fdm/jsbsim/systems/carrier/cat1-lat-position");
              var dest_lon = getprop("/fdm/jsbsim/systems/carrier/cat1-lon-position");
           }
           if (taxi_to == 2){
              var dest_lat = getprop("/fdm/jsbsim/systems/carrier/cat2-lat-position");
              var dest_lon = getprop("/fdm/jsbsim/systems/carrier/cat2-lon-position");
           }
           if (taxi_to == 3){
              var dest_lat = getprop("/fdm/jsbsim/systems/carrier/cat3-lat-position");
              var dest_lon = getprop("/fdm/jsbsim/systems/carrier/cat3-lon-position");
           }
           if (taxi_to == 4){
              var dest_lat = getprop("/fdm/jsbsim/systems/carrier/cat4-lat-position");
              var dest_lon = getprop("/fdm/jsbsim/systems/carrier/cat4-lon-position");
           }
              var pos = geo.Coord.set_latlon(dest_lat,dest_lon);
              var ac_pos = geo.aircraft_position();
              var taxi_distance = ac_pos.distance_to(pos);
              var taxi_course = ac_pos.course_to(pos);
#print (taxi_to," ",taxi_distance, " ",taxi_course );
              setprop("/fdm/jsbsim/systems/taxi/distance",taxi_distance);
              setprop("/fdm/jsbsim/systems/taxi/course",taxi_course);
settimer(taxi_op,1);
}
}
setlistener("/sim/model/taxi/linked",taxi_op);

taxi_message=func{
          if (getprop("/sim/model/taxi/linked") and getprop("/sim/carrier/name") != "none"){
          var taxi_to = getprop("/sim/model/taxi/taxi_to");
          var text_taxi_to = "Your are going to Catapult number  " ~ taxi_to;
          var window = screen.window.new(nil, -100, 3, 50);
                      window.write("");
                      window.write(text_taxi_to);
          }
          #else{
          #var text_taxi_to = "Your request is not valid";
          #var window = screen.window.new(nil, -100, 3, 50);
          #            window.write("");
          #            window.write(text_taxi_to);
          #}
}
setlistener("/sim/model/taxi/linked",taxi_message);