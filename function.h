#ifndef FUNCTION_H
#define FUNCTION_H 1
#include <limits.h>
#include "RooRealVar.h"
#include "RooStats/SPlot.h"
#include "RooDataSet.h"
#include "RooDataHist.h"
#include "RooGaussian.h"
#include "RooBreitWigner.h"
#include "RooChebychev.h"
#include "RooAddPdf.h"
#include "RooAddition.h"
#include "RooPlot.h"
#include "RooFitResult.h"
#include "RooProdPdf.h"
#include "RooProduct.h"
#include "RooCBShape.h"
#include "TSystem.h"
#include "RooFitResult.h"

#include "TCanvas.h"
#include "TROOT.h"
#include "TStyle.h"
#include "TLegend.h"
#include "TAxis.h"

#include <iostream>
#include <fstream>
#include <string>
#include <climits>
#include <vector>
#include "TCanvas.h"
#include "TGraph.h"
#include "var.h"
// use this order for safet on library loading
using namespace std;
using namespace RooFit;
using namespace RooStats;

// Global variables
TStyle *myStyle = new TStyle("myStyle", "my Style");
RooArgSet variables;

//Class holds results of fit, constructed by function fitData() 
class myresult
{
public:
    double merit;// S/sqrt(S + B)
    double mySfromData;// S
    double myBfromData;// B
    double tem;// Tried position (not used)
    bool fitquality = 0;// fit quality, 1 for good fit and 0 for bad fit
};

//Print all elements in a vector<double> in a line with , spliting and with a title str:
void print(string str, vector<double> vec)
{
    if (vec.size() > 0)
    {
        cout << str << " : ";
        for (long unsigned int j = 0; j < vec.size(); j++)
        {
            cout << vec[j] << ", ";
        }
        cout << endl;
    }
}

void myset(TStyle *myStyle, RooArgSet &variables)
{
    //Set Drawing Style
    myStyle->SetCanvasBorderMode(0);
    myStyle->SetCanvasColor(10);
    myStyle->SetPadBorderMode(0);
    myStyle->SetPadColor(10);
    myStyle->SetPadBottomMargin(0.15);
    myStyle->SetPadLeftMargin(0.15);
    myStyle->SetPaperSize(18, 24);
    myStyle->SetLabelSize(0.04, "XY");
    myStyle->SetLabelOffset(0.01, "Y");
    myStyle->SetTitle("");
    myStyle->SetOptStat(00000);
    myStyle->SetTitleOffset(1, "XY");
    myStyle->SetTitleSize(0.06, "XY");
    gROOT->SetStyle("myStyle");

    //Please add all cut variables here
    //Cut variables are declared in var h file
    variables.add(psi2s_mass);
    //Add_Other_Variables_Here
}

//Print with title str : and , spliting; Print all elements; Print maximum in vec2 and
//elements in vec1 with the same index, format is Max = vec1_same_index : maximun vec2
void print_vectors(string str, vector<double> vec1, vector<double> vec2)
{
    if (vec1.size() > 0 && vec2.size() > 0)
    {
        double max_vec2 = vec2[0];
        double cor_vec1 = vec1[0];
        cout << str << " : " << endl;
        for (int j = 0; j < vec1.size(); j++)
        {
            cout << vec1[j] << ", ";
        }
        cout << endl;
        for (int j = 0; j < vec2.size(); j++)
        {
            cout << vec2[j] << ", ";
            if (vec2[j] > max_vec2)
            {
                max_vec2 = vec2[j];
                cor_vec1 = vec1[j];
            }
        }
        cout << endl
             << str << "Max = " << cor_vec1 << " : " << max_vec2 << endl;
    }
}
// Override version for saving a file with name fileName.txt
void print_vectors(const char* fileName, string str, vector<double> vec1, vector<double> vec2)
{
    std::ofstream file;
    std::string text = fileName;
    text = text + ".txt";
    file.open(text.c_str(), std::ios::out);
    if (vec1.size() > 0 && vec2.size() > 0)
    {
        double max_vec2 = vec2[0];
        double cor_vec1 = vec1[0];
        file << str << " : " << endl;
        for (int j = 0; j < vec1.size(); j++)
        {
            file << vec1[j] << ", ";
        }
        file << endl;
        for (int j = 0; j < vec2.size(); j++)
        {
            file << vec2[j] << ", ";
            if (vec2[j] > max_vec2)
            {
                max_vec2 = vec2[j];
                cor_vec1 = vec1[j];
            }
        }
        file << endl
             << str << "Max = " << cor_vec1 << " : " << max_vec2 << endl;
    }
}
//Draw a plot use vecotr x as x_data and y as y_data, the x axis title is str
void drawVectors(const char *str, vector<double> x, vector<double> y)
{
    TCanvas *canvas = new TCanvas("c1", "my graph", 200, 10, 700, 500);
    TGraph *gr = new TGraph(x.size(), &x[0], &y[0]);//Load graph from vector x and y, note that they must have the same dimension
    gr->SetTitle("Figure of Merit");
    gr->GetXaxis()->SetTitle(str);
    gr->GetYaxis()->SetTitle("Merit");
    gr->Draw("AL");//A: Draw axis; L: Draw ployline to make a plot
    gr->SetLineWidth(7);
}
// Override version for saving a file in fileName.png
void drawVectors(const char *fileName, const char *str, vector<double> x, vector<double> y)
{
    TCanvas *canvas = new TCanvas("c1", "my graph", 200, 10, 700, 500);
    TGraph *gr = new TGraph(x.size(), &x[0], &y[0]);//Load graph from vector x and y, note that they must have the same dimension
    std::string tempStr = "Figure of Merit";
    tempStr = tempStr + fileName;
    gr->SetTitle(tempStr.c_str());
    gr->GetXaxis()->SetTitle(str);
    gr->GetYaxis()->SetTitle("Merit");
    gr->Draw("AL");//A: Draw axis; L: Draw ployline to make a plot
    gr->SetLineWidth(7);
    tempStr = fileName;
    tempStr = tempStr + ".png"; 
    canvas->SaveAs(tempStr.c_str());
}

//Do a fit and culculate merit
myresult fitData(RooDataSet *data, bool isDraw = false)
{
    //Set signal and background PDF and paramiters
    //signal: double cristal ball by certain fraction
    //background: 2th order Chebychev for Jpsi and 3th order Chebychev for Psi2s
   
    // signal config
    double meanCB;
    if(isDraw)
    {
	    meanCB = 3.68619e+00;
    }else
    {
	    meanCB = 3.872e+00; // For spacial fit when drawing result
    }

    RooRealVar meanCB1_psi2s("meanCB1_psi2s", "meanCB1_psi2s", 3.68619e+00, psi2s_mass_Min, psi2s_mass_Max);
    RooRealVar sigmaCB1_psi2s("sigmaCB1_psi2s", "sigmaCB1_psi2s", 9.59592e-03, 0., 0.01);
    RooRealVar nCB1_psi2s("nCB1_psi2s", "nCB1_psi2s", 1.99999e+01);
    RooRealVar alphaCB1_psi2s("alphaCB1_psi2s", "alphaCB1_psi2s", 1.99999e+00);
    RooCBShape CB1_psi2s("CB1_psi2s", "CB1_psi2s", psi2s_mass,
                         meanCB1_psi2s, sigmaCB1_psi2s, alphaCB1_psi2s, nCB1_psi2s);

    RooRealVar sigmaCB2_psi2s("sigmaCB2_psi2s", "sigmaCB2_psi2s", 5.28500e-03, 0, 0.01);
    RooRealVar nCB2_psi2s("nCB2_psi2s", "nCB2_psi2s", 7.38216e-01);
    RooRealVar alphaCB2_psi2s("alphaCB2_psi2s", "alphaCB2_psi2s", 5.35155e+00);
    RooCBShape CB2_psi2s("CB2_psi2s", "CB2_psi2s", psi2s_mass,
                         meanCB1_psi2s, sigmaCB2_psi2s, alphaCB2_psi2s, nCB2_psi2s);

    RooRealVar fracCB1_psi2s("fracCB1_psi2s", "fracCB1_psi2s", 5.14370e-01);
    RooAddPdf psi2s_double_CB_Fcn("psi2s_double_CB_Fcn", "psi2s_double_CB_Fcn",
                                  RooArgList(CB1_psi2s, CB2_psi2s), fracCB1_psi2s);

    // background config
    RooRealVar c1_bkg_psi2s("c1_bkg_psi2s", "c1_bkg_psi2s", 1.35819e-01, -0.8, 0.8);
    RooRealVar c2_bkg_psi2s("c2_bkg_psi2s", "c2_bkg_psi2s", -4.91313e-02, -0.6, 0.6);
    RooRealVar c3_bkg_psi2s("c3_bkg_psi2s", "c3_bkg_psi2s", 5.91313e-02, -0.07, 0.07);
    RooChebychev bkg_psi2s_Fcn("bkg_psi2s_Fcn", "bkg_psi2s_Fcn", psi2s_mass, RooArgList(c1_bkg_psi2s, c2_bkg_psi2s, c3_bkg_psi2s));

    // Fraction of psi2s and bkg, also total event numbers of each
    RooRealVar n_psi2s("n_psi2s", "n_psi2s", 0, 0, 100000);
    RooRealVar n_bkg_psi2s("n_bkg_psi2s", "n_bkg_psi2s", 1000, 0, 100000);

    RooAddPdf totalPdf("totalPdf", "totalPdf", RooArgList(psi2s_double_CB_Fcn, bkg_psi2s_Fcn), RooArgList(n_psi2s, n_bkg_psi2s));

    //Make mass of Psi2s constant
    if(!isDraw)
    {
    // sigmaCB1_jpsi.setConstant(kTRUE);
    sigmaCB1_psi2s.setConstant(kTRUE);
    // sigmaCB2_jpsi.setConstant(kTRUE);
    sigmaCB2_psi2s.setConstant(kTRUE);
    	meanCB1_psi2s.setConstant(kTRUE);
    }

    double tem = 1.35819e-01;
    double Data_edm;
    int Data_status, Data_covQual;
    RooFitResult *fitRes;
    unsigned int ii = 0;
    while (true)
    {
        c1_bkg_psi2s.setVal(tem);
        fitRes = totalPdf.fitTo(*data, Hesse(kTRUE), Strategy(2), NumCPU(8), Save(kTRUE), Minos(kFALSE), PrintLevel(-1), Warnings(-1), PrintEvalErrors(-1));//Fit total PDF
        Data_edm = fitRes->edm();
        Data_status = fitRes->status();
        Data_covQual = fitRes->covQual();
	ii = ii + 1;
        if ((Data_edm < 0.01 && Data_status == 0 && Data_covQual == 3) || ii >= 100)
        {
            break;
        }
        tem += 0.0001;
    }

    // double x1min = 3.6861 - 0.01 * 3; // psi2s mean massErr 10 MeV, 3 mass window
    // double x1max = 3.6861 + 0.01 * 3;
    // double x2min = 3.0969 - 0.03 * 3; // jpsi mean massErr 30 MeV, 3 mass window
    // double x2max = 3.0969 + 0.03 * 3;
    double x1min = psi2s_mass_Min; // psi2s mean massErr 10 MeV, 3 mass window
    double x1max = psi2s_mass_Max;
    psi2s_mass.setRange("massPeak", x1min, x1max);

    // only consider events under psi2s mass peak

    double areabkglimit = bkg_psi2s_Fcn.createIntegral(RooArgSet(psi2s_mass), Range("massPeak"))->getVal(); 
    double areasiglimit = psi2s_double_CB_Fcn.createIntegral(RooArgSet(psi2s_mass), Range("massPeak"))->getVal();

    double areabkgtotal = bkg_psi2s_Fcn.createIntegral(RooArgSet(psi2s_mass))->getVal();
    double areasigtotal = psi2s_double_CB_Fcn.createIntegral(RooArgSet(psi2s_mass))->getVal(); 

    // Compute fraction of events under range of the mass peak, that is the fanal S/B is the result under the peak
    double fraclimitbkg = areabkglimit / areabkgtotal;
    double fraclimitsig = areasiglimit / areasigtotal;

    cout << "fraclimitbkg: " << fraclimitbkg << endl;
    cout << "fraclimitsig: " << fraclimitsig << endl;

    // getntotal
    double nbkgTotal = n_bkg_psi2s.getVal();
    double nsigTotal = n_psi2s.getVal();

    cout << "nbkgTotal: " << nbkgTotal << endl;
    cout << "nsigTotal:" << nsigTotal << endl;

    // getnlimit
    double nbkglimit = nbkgTotal * fraclimitbkg;
    double nsiglimit = nsigTotal * fraclimitsig;

    cout << "nbkglimit:" << nbkglimit << endl;
    cout << "nsiglimit:" << nsiglimit << endl;

    double myBfromData = nbkglimit;
    double mySfromData = nsiglimit;

    cout << "mySfromData = " << mySfromData << endl;
    cout << "myBfromData = " << myBfromData << endl;

    cout << "Data_edm = " << Data_edm << endl;
    cout << "Data_status = " << Data_status << endl;
    cout << "Data_covQual = " << Data_covQual << endl;
    myresult myroofitresult;
    myroofitresult.merit = mySfromData / sqrt(myBfromData + mySfromData);
    myroofitresult.myBfromData = myBfromData;
    myroofitresult.mySfromData = mySfromData;
    myroofitresult.tem = tem;
    if (Data_edm < 0.01 && Data_status == 0 && Data_covQual == 3)
    {
        myroofitresult.fitquality = 1;
    }
    // Draw a graph if isDraw is true
    if(!isDraw)
    {
    	RooPlot *myframe = psi2s_mass.frame();
    	data->plotOn(myframe);
    	psi2s_double_CB_Fcn.plotOn(myframe, LineColor(kRed));
    	bkg_psi2s_Fcn.plotOn(myframe, LineColor(kBlack));
    	totalPdf.plotOn(myframe, LineColor(kBlue)); 
    	myframe->Draw();
    }
    ii = 0;
    return myroofitresult;
}

#endif
