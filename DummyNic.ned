// DummyNic.ned
// Minimal placeholder NIC so OMNeT++ can instantiate a 'Nic80211p'
// without pulling in the full Veins networking implementation or asking for parameters.
// This intentionally has no parameters and very simple gates.

simple Nic80211p
{
    parameters:
        @display("i=device/wifi");
    gates:
        inout upperLayerIn;
        inout lowerLayerOut;
}
