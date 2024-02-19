#include "TFile.h"
#include "TCanvas.h"
#include "TROOT.h"

#include <vector>
#include <iostream>
#include <string>
#include "function.h"

#define Names std::vector<std::string>

void Execute()
{
	myset(myStyle, variables);

	Names * name = new Names();
	// Register file names here
	

	unsigned int num = name->size();
	std::string cmd;
	for(unsigned int i = 0; i < num; i++)
	{
		std::cout<<"I am processing "<<name->at(i)<<std::endl;
		std::cout<<"This is "<<i + 1<<" out of "<<num<<std::endl;
                cmd = ".x " + name->at(i);
                std::cout<<cmd.c_str()<<std::endl;
                gROOT->ProcessLine(cmd.c_str());
	}
}
