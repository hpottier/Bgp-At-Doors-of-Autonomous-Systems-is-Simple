#!/bin/sh
docker build . -t router_hpottier -f router_hpottier
gns3 P1.gns3project
