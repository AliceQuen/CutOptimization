#ifndef VAR_HH
#define VAR_HH 1
int stepnum = 25; // how many points to plot

// Mass range of psi2s_mass, which is final mass target
// float psi2s_mass_Min = 3.68, psi2s_mass_Max = 3.70;// Mass peak range
   float psi2s_mass_Min = 3.60, psi2s_mass_Max = 3.80;
   float jpsi_mass_Min = 2.8, jpsi_mass_Max = 3.4;


// Set all cut variables
// RooReaVar("name", "title", min, max) (primary value is the mid point of the range)

// Variable definations here
RooRealVar psi2s_mass("psi2s_mass", "M(#mu#mu#pi#pi)-M(#mu#mu)+3.0969 GeV", psi2s_mass_Min, psi2s_mass_Max);
RooRealVar jpsi_mass("jpsi_mass", "M(#mu#mu) GeV", jpsi_mass_Min, jpsi_mass_Max);// only used in 2D fit, if use 1D, please delete this line
#endif
