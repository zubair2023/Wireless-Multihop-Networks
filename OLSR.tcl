#
# NS 2 code for simulating the OLSR routing protocol for MANET
#
# Define options
#
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(ant) Antenna/OmniAntenna ;# Antenna type
set val(ll) LL ;# Link layer type
set val(ifq) CMUPriQueue ;# Interface queue type
set val(ifqlen) 50 ;# max packet in ifq
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(rp) OLSR ;# ad-hoc routing protocol
#CHANGE NUMBER OF NODES ON EACH SIMULATION
set val(nn) 100 ;# number of mobile nodes
set val(x) 600 ;# X dimension of the topography
set val(y) 600 ;# Y dimension of the topography
set val(seed) 1.0
#Global cbrgen file for OLSR protocol
set val(cp) "./indep-utils/cmu-scen-gen/cbrgen-network-load-100"
#Varying Node speed test
set val(sc) "./indep-utils/cmu-scen-gen/setdest/setdest-network-load-100"
set val(stop) 240 ;# simulation time
# Create simulator
set ns_ [new Simulator]
Agent/OLSR set use_mac_ true
# Set up trace file
set tracefd [open OLSR-netload-100-out.tr w] ;# for wireless traces
$ns_ trace-all $tracefd
set namtrace [open OLSR-netload-100-out.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
# Create the "general operations director"
# Used internally by MAC layer: must create!
create-god $val(nn)
# Create and configure topography (used for mobile scenarios)
set topo [new Topography]
$topo load_flatgrid 600 600
$ns_ node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channel [new $val(chan)] \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace OFF
for {set i 0} {$i < $val(nn) } {incr i} {
set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
$node_($i) set X_ [expr 10+round(rand()*480) ]
$node_($i) set X_ [expr 10+round(rand()*380) ]
$node_($i) set Z_ 0.0
}
# Define traffic model
puts "Loading connection pattern..."
source $val(cp)
# Define node movement model
puts "Loading scenario file..."
source $val(sc)
# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
# 20 defines the node size in nam, must adjust it according to your scenario
# The function must be called after mobility model is defined
$ns_ initial_node_pos $node_($i) 20
}
# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
puts "Starting Simulation..."
$ns_ run
$ns_ flush-trace
close $tracefd
