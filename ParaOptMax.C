// This is a templete for creating scripts to find a cut point of maximum of a variable
// which means this variable will have a varying upper bundary
#include "function.h"
using namespace std;
using namespace RooFit;
using namespace RooStats;

void VarName_TaskName()
{
	// myset(myStyle, variables);
	// If you want to run without Execute.C, use this to initialize
	
	vector<double> numS, numB, TEM, x_Data, y_Data;
	for (double tem_VarName = VarName_MaxOpt; tem_VarName > VarName_MinOpt; tem_VarName -= (VarName_MaxOpt - VarName_MinOpt) / stepnum)
	{
		VarName.setRange(VarName_Min, tem_VarName);// Set cut as tem, which increase gradually
		RooDataSet *data = RooDataSet::read("Data_List",
		variables, "Q", "DataDir", nullptr);
		if( data->sumEntries() == 0 )
		{
			break;
		}
		//Load data read only data from range of optimazed variable;
		// Q is for quiet and D for verbose; 'data/' is data file directory, nullptr by default
		// Each cloumb of the txt file will be read as a variable, accroding to order in variables
		// Cloumb number should match number of variables in 'variables', exceeding lines will be ignored
		// Cloumb with data out of range in 'variables' will also be ignored
		// The first cloumb should be Psi2s Mass and will be used for fitting
		// Multi-files can be used, just substitute 'Data_List' with comma seperated file list

		myresult myroofitresult = fitData(data);
		
		//For good quality fit, save thier results
		if (myroofitresult.fitquality == 1)
		{
			x_Data.push_back(tem_VarName);
			y_Data.push_back(myroofitresult.merit);
			numS.push_back(myroofitresult.mySfromData);
			numB.push_back(myroofitresult.myBfromData);
			TEM.push_back(myroofitresult.tem);
		}
		delete data;
	}

	//Print results and Draw merit plot
	if (x_Data.size() > 0)
	{
	//	print("tem", TEM);// All good fit cut position
	//	print("numS", numS);// Signal number
	//	print("numB", numB);// Background number
	   	//Draw and print S/sqrt(S+B) as function of cut position
		print_vectors("result/TaskName_result/VarName", "Psi2s_SfromData", x_Data, y_Data);
		drawVectors("result/TaskName_result/VarName", "VarName_merit_max", x_Data, y_Data);
	}
	VarName.setRange(VarName_Min, VarName_Max);// Reset range for next fit
}
