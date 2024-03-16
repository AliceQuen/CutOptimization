#include "function.h"
using namespace std;
using namespace RooFit;
using namespace RooStats;
void DrawCut()
{
	myset(myStyle, variables);
	psi2s_mass.setRange(3.8, 3.95);
	RooDataSet *data = RooDataSet::read("Data_List", variables, "Q", "DataDir", nullptr);
	myresult result = fitData(data, true); 
	psi2s_mass.setRange(psi2s_mass_Min, psi2s_mass_Max);
}
