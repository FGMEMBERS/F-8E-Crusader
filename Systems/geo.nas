# geo functions
# -------------------------------------------------------------------------------------------------
# geo.Coord.new([<coord>])        ... class that holds and maintains geographical coordinates
#                                     can be initialized with another geo.Coord instance
#     Coord.set(<coord>)          ... sets coordinates from another geo.Coord instance
#
#     Coord.set_lat(<num>)        ... functions for setting latitude/longitude/altitude
#     Coord.set_lon(<num>)
#     Coord.set_alt(<num>)
#     Coord.set_latlon(<num>, <num> [, <num>])      (altitude is optional; default=0)
#
#     Coord.set_x(<num>)          ... functions for setting cartesian x/y/z coordinates
#     Coord.set_y(<num>)
#     Coord.set_z(<num>)
#     Coord.set_xyz(<num>, <num>, <num>)
#
#     Coord.lat()
#     Coord.lon()                 ... functions for getting lat/lon/alt
#     Coord.alt()                     ... returns altitude in m
#     Coord.latlon()                  ... returns array  [<lat>, <lon>, <alt>]
#
#     Coord.x()                   ... functions for reading cartesian coords (in m)
#     Coord.y()
#     Coord.z()
#     Coord.xyz()                     ... returns array  [<x>, <y>, <z>]
#
#     Coord.course_to(<coord>)    ... returns course to another geo.Coord instance (degree)
#     Coord.distance_to(<coord>)  ... returns distance in m along Earth curvature, ignoring altitudes
#                                     useful for map distance
#     Coord.direct_distance_to(<coord>) ...   distance in m direct, considers altitude,
#                                             but cuts through Earth surface
#
#     Coord.apply_course_distance(<course>, <distance>)       ... guess what
#     Coord.dump()                ... outputs coordinates
#     Coord.is_defined()          ... returns whether the coords are defined
#
# geo.aircraft_position()         ... returns current aircraft position as geo.Coord
# geo.click_position()            ... returns last click coords as geo.Coord or nil before first click
#
# geo.tile_path(<lat>, <lon>)     ... returns tile path string (e.g. "w130n30/w123n37/942056.stg")
# geo.elevation(<lat>, <lon>)     ... returns elevation in meter for given lat/lon, or nil on error
# geo.normdeg(<angle>)            ... returns angle normalized to  0 <= angle < 360
#
# geo.put_model(<path>, <lat>, <lon> [, <elev:nil> [, <hdg:0> [, <pitch:0> [, <roll:0>]]]]);
#                                 ... put model <path> at location <lat>/<lon> with given elevation
#                                     (optional, default: surface). <hdg>/<pitch>/<roll> are optional
#                                     and default to zero.
# geo.put_model(<path>, <coord> [, <hdg:0> [, <pitch:0> [, <roll:0>]]]);
#                                 ... same as above, but lat/lon/elev are taken from a Coord object


var EPSILON = 0.0000000000001;
var ERAD = 6378138.12;		# Earth radius (m)
var D2R = math.pi / 180;
var R2D = 180 / math.pi;
var FT2M = 0.3048;
var M2FT = 3.28083989501312335958;


var floor = func(v) { v < 0.0 ? -int(-v) - 1 : int(v) }
var sin = nil;
var cos = nil;
var atan2 = nil;
var sqrt = nil;
var asin = nil;
var acos = nil;
var mod = nil;


# class that maintains one set of geographical coordinates
#
var Coord = {
	new : func(copy = nil) {
		var m = { parents: [Coord] };
		m._pdirty = 1;  # polar
		m._cdirty = 1;  # cartesian
		m._lat = nil;   # in radian
		m._lon = nil;   #
		m._alt = nil;   # ASL
		m._x = nil;     # in m
		m._y = nil;
		m._z = nil;
		if (copy != nil)
			m.set(copy);

		return m;
	},
	_cupdate : func {
		me._cdirty or return;
		var xyz = geodtocart(me._lat * R2D, me._lon * R2D, me._alt);
		me._x = xyz[0];
		me._y = xyz[1];
		me._z = xyz[2];
		me._cdirty = 0;
	},
	_pupdate : func {
		me._pdirty or return;
		var lla = carttogeod(me._x, me._y, me._z);
		me._lat = lla[0] * D2R;
		me._lon = lla[1] * D2R;
		me._alt = lla[2];
		me._pdirty = 0;
	},

	x : func { me._cupdate(); me._x },
	y : func { me._cupdate(); me._y },
	z : func { me._cupdate(); me._z },
	xyz : func { me._cupdate(); [me._x, me._y, me._z] },

	lat : func { me._pupdate(); me._lat * R2D },  # return in degree
	lon : func { me._pupdate(); me._lon * R2D },
	alt : func { me._pupdate(); me._alt },
	latlon : func { me._pupdate(); [me._lat * R2D, me._lon * R2D, me._alt] },

	set_x : func(x) { me._pupdate(); me._pdirty = 1; me._x = x; me },
	set_y : func(y) { me._pupdate(); me._pdirty = 1; me._y = y; me },
	set_z : func(z) { me._pupdate(); me._pdirty = 1; me._z = z; me },

	set_lat : func(lat) { me._cupdate(); me._cdirty = 1; me._lat = lat * D2R; me },
	set_lon : func(lon) { me._cupdate(); me._cdirty = 1; me._lon = lon * D2R; me },
	set_alt : func(alt) { me._cupdate(); me._cdirty = 1; me._alt = alt; me },

	set : func(c) {
		c._pupdate();
		me._lat = c._lat;
		me._lon = c._lon;
		me._alt = c._alt;
		me._cdirty = 1;
		me._pdirty = 0;
		me;
	},
	set_latlon : func(lat, lon, alt = 0) {
		me._lat = lat * D2R;
		me._lon = lon * D2R;
		me._alt = alt;
		me._cdirty = 1;
		me._pdirty = 0;
		me;
	},
	set_xyz : func(x, y, z) {
		me._x = x;
		me._y = y;
		me._z = z;
		me._pdirty = 1;
		me._cdirty = 0;
		me;
	},
	apply_course_distance : func(course, dist) {
		me._pupdate();
		course *= D2R;
		dist /= ERAD;
		me._lat = asin(sin(me._lat) * cos(dist) + cos(me._lat) * sin(dist) * cos(course));

		if (cos(me._lat) > EPSILON)
			me._lon = math.pi - mod(math.pi - me._lon - asin(sin(course) * sin(dist)
					/ cos(me._lat)), 2 * math.pi);

		me._cdirty = 1;
		me;
	},
	course_to : func(dest) {
		me._pupdate();
		dest._pupdate();

		if (me._lat == dest._lat and me._lon == dest._lon)
			return 0;

		var dlon = dest._lon - me._lon;
		return mod(atan2(sin(dlon) * cos(dest._lat), cos(me._lat) * sin(dest._lat)
				- sin(me._lat) * cos(dest._lat) * cos(dlon)), 2 * math.pi) * R2D;
	},
	# arc distance on an earth sphere; doesn't consider altitude
	distance_to : func(dest) {
		me._pupdate();
		dest._pupdate();

		if (me._lat == dest._lat and me._lon == dest._lon)
			return 0;

		var a = sin((me._lat - dest._lat) * 0.5);
		var o = sin((me._lon - dest._lon) * 0.5);
		return 2.0 * ERAD * asin(sqrt(a * a + cos(me._lat) * cos(dest._lat) * o * o));
	},
	direct_distance_to : func(dest) {
		me._cupdate();
		dest._cupdate();
		var dx = dest._x - me._x;
		var dy = dest._y - me._y;
		var dz = dest._z - me._z;
		return sqrt(dx * dx + dy * dy + dz * dz);
	},
	is_defined : func {
		return !(me._cdirty and me._pdirty);
	},
	dump : func {
		if (me._cdirty and me._pdirty)
			print("Coord.print(): coord undefined");

		me._cupdate();
		me._pupdate();
		printf("x=%f  y=%f  z=%f    lat=%f  lon=%f  alt=%f",
				me.x(), me.y(), me.z(), me.lat(), me.lon(), me.alt());
	},
};


# normalize degree to 0 <= angle < 360
#
var normdeg = func(angle) {
	while (angle < 0)
		angle += 360;
	while (angle >= 360)
		angle -= 360;
	return angle;
}


var bucket_span = func(lat) {
	if (lat >= 89.0)
		360.0;
	elsif (lat >= 88.0)
		8.0;
	elsif (lat >= 86.0)
		4.0;
	elsif (lat >= 83.0)
		2.0;
	elsif (lat >= 76.0)
		1.0;
	elsif (lat >= 62.0)
		0.5;
	elsif (lat >= 22.0)
		0.25;
	elsif (lat >= -22.0)
		0.125;
	elsif (lat >= -62.0)
		0.25;
	elsif (lat >= -76.0)
		0.5;
	elsif (lat >= -83.0)
		1.0;
	elsif (lat >= -86.0)
		2.0;
	elsif (lat >= -88.0)
		4.0;
	elsif (lat >= -89.0)
		8.0;
	else
		360.0;
}


var tile_index = func(lat, lon) {
	var lat_floor = floor(lat);
	var lon_floor = floor(lon);
	var span = bucket_span(lat);
	var x = 0;

	if (span < 0.0000001) {
		lon = 0;
	} elsif (span <= 1.0) {
		x = int((lon - lon_floor) / span);
	} else {
		if (lon >= 0) {
			lon = int(int(lon / span) * span);
		} else {
			lon = int(int((lon + 1) / span) * span - span);
			if (lon < -180)
				lon = -180;
		}
	}

	var y = int((lat - lat_floor) * 8);
	return (lon_floor + 180) * 16384 + (lat_floor + 90) * 64 + y * 8 + x;
}


var format = func(lat, lon) {
	sprintf("%s%03d%s%02d", lon < 0 ? "w" : "e", abs(lon), lat < 0 ? "s" : "n", abs(lat));
}


var tile_path = func(lat, lon) {
	var p = format(floor(lat / 10.0) * 10, floor(lon / 10.0) * 10);
	p ~= "/" ~ format(floor(lat), floor(lon));
	p ~= "/" ~ tile_index(lat, lon) ~ ".stg";
}


var put_model = func(path, c, arg...) {
	call(_put_model, [path] ~ (isa(c, Coord) ? c.latlon() : [c]) ~ arg);
}


var _put_model = func(path, lat, lon, elev_m = nil, hdg = 0, pitch = 0, roll = 0) {
	if (elev_m == nil)
		elev_m = elevation(lat, lon);
	if (elev_m == nil)
		die("geo.put_model(): can't get elevation for " ~ lat ~ "/" ~ lon);
	var n = props.globals.getNode("/models");
	for (var i = 0; 1; i += 1)
		if (n.getChild("model", i, 0) == nil)
			break;
	n = n.getChild("model", i, 1);
	n.getNode("path", 1).setValue(path);
	n.getNode("latitude-deg", 1).setDoubleValue(lat);
	n.getNode("longitude-deg", 1).setDoubleValue(lon);
	n.getNode("elevation-ft", 1).setDoubleValue(elev_m * M2FT);
	n.getNode("heading-deg", 1).setDoubleValue(hdg);
	n.getNode("pitch-deg", 1).setDoubleValue(pitch);
	n.getNode("roll-deg", 1).setDoubleValue(roll);
	n.getNode("load", 1).setBoolValue(1);
	n.removeChildren("load");
	return n;
}


var elevation = func(lat, lon) {
	var d = geodinfo(lat, lon);
	return d == nil ? nil : d[0];
}


var aircraft_lat = nil;
var aircraft_lon = nil;
var aircraft_alt = nil;

var aircraft_position = func {
	var lat = aircraft_lat.getValue();
	var lon = aircraft_lon.getValue();
	var alt = aircraft_alt.getValue() * FT2M;
	return Coord.new().set_latlon(lat, lon, alt);
}


var click_lat = nil;
var click_lon = nil;
var click_elev = nil;
var click_coord = Coord.new();

_setlistener("/sim/signals/click", func {
	var lat = click_lat.getValue();
	var lon = click_lon.getValue();
	var elev = click_elev.getValue();
	click_coord.set_latlon(lat, lon, elev);
});

var click_position = func {
	return click_coord.is_defined() ? Coord.new(click_coord) : nil;
}



_setlistener("/sim/signals/nasal-dir-initialized", func {
	sin = math.sin;
	cos = math.cos;
	atan2 = math.atan2;
	sqrt = math.sqrt;
	asin = math.asin;
	acos = math.acos;
	mod = math.mod;

	aircraft_lat = props.globals.getNode("/position/latitude-deg", 1);
	aircraft_lon = props.globals.getNode("/position/longitude-deg", 1);
	aircraft_alt = props.globals.getNode("/position/altitude-ft", 1);

	click_lat = props.globals.getNode("/sim/input/click/latitude-deg", 1);
	click_lon = props.globals.getNode("/sim/input/click/longitude-deg", 1);
	click_elev = props.globals.getNode("/sim/input/click/elevation-m", 1);
});

