//
//  DistHubeny.m
//  McdDemo
//
//  Created by Yuumi Yoshida on 10/01/07.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "DistHubeny.h"

#include <math.h>
#include <stdio.h>


#define A 6378137.000
#define E2 0.00669437999019758
#define MNUM 6335439.32729246

#define DEG2RAD(d) ((d) * M_PI / 180.0)

double calcDistHubeny(double lat1, double lng1, double lat2, double lng2) {
	double my = DEG2RAD((lat1 + lat2) / 2.0);
	double dy = DEG2RAD(lat1 - lat2);
	double dx = DEG2RAD(lng1 - lng2);
	
	double s = sin(my);
	double w = sqrt(1.0 - E2 * s * s);
	double m = MNUM / (w * w * w);
	double n = A / w;
	
	double dym = dy * m;
	double dxncos = dx * n * cos(my);
	
	return sqrt(dym * dym + dxncos * dxncos);
}


extern char *distanceFormat(double distance) {
	static char buff[32];
	
	if (distance < 1000.0)
		sprintf(buff, "%.0fm", distance);
	else
		sprintf(buff, "%.1fKm", distance / 1000.0);
	
	return buff;
}

	
