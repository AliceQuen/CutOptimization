#!/bin/bash
# Please first run this script to generate files for cut optimization
# Substitute variables below to what you want 

# Task information
taskName='cutOpt5'
dataDir="/home/qjk/JPsiX3872/Cut4/"

# Variables
declare -a varName 
declare -a varMax # Range for primary cut
declare -a varMin 
declare -a varMaxOpt # Range for cut to vary
declare -a varMinOpt
declare -a varType # Variable for deciding varying upper bundary or lower bundary. 0 for upper and 1 for lower

#varName=(psi2s_jpsi_dR pi1 varMax=(0.0228 10000 10000 0.6492 1.7472 1.7472 10000.0 10000 10000 0.2944 0.2944 100 2.159 1.5320 3.74 3.74 3.632 3.632 0    .0476 0.0466 10000 10000)_pt pi2_pt pi_pi_dR pi1_eta_abs pi2_eta_abs psi2s_pt pi1_pz_abs pi2_pz_abs psi2s_pi1_dR
#psi2s_pi2_dR tight_mu jpsi_eta_abs psi2s_eta_abs jpsi_mu1_dR jpsi_mu2_dR psi2s_mu1_dR psi2s_mu2_dR jpsi_mass_err
#psi2s_mass_err jpsi_vtx psi2s_vtx)
#varMax=(0.14 3.55 3.55 1.1 3.0 3.0 100.0 9.0 9.0 0.55 0.55 3.5 3.0 3.0 6.0 6.0 6.0 4.5 0.1 0.1 1.0 1.0)
#varMin=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
#varType=(0 1 1 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0) #  from cut2
#

#varName=(jpsi_eta_abs jpsi_mass_err jpsi_mu1_dR jpsi_mu2_dR pi_pi_dR pi1_eta_abs pi2_eta_abs pi1_pt pi2_pt psi2s_pi1_dR
#	psi2s_pi2_dR psi2s_mu1_dR psi2s_mu2_dR psi2s_eta_abs psi2s_jpsi_dR psi2s_mass_err psi2s_pt)
# varMax=(2.159 0.0476 3.74 3.74 0.6492 1.7472 1.7472 10000 10000 0.2994 0.2994 3.632 3.632 1.532 0.0228 0.04666 10000)
# varMin=(-10000 -10000 -10000 -10000 -10000 -10000 -10000 0.772 0.772 -10000 -10000 -10000 -10000 -10000 -10000 -10000 11.736)
# varMaxOpt=(2.4 0.06 4.5 4.5 0.8 2.0 2.0 1.25 1.25 0.35 0.35 4.0 4.0 2.50 0.04 0.065 20)
# varMinOpt=(2.0 0.03 3.3 3.3 0.5 1.25 1.25 0.5 0.5 0.25 0.25 3.0 3.0 1.25 0.02 0.03 10)
# varType=(0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1)
# varMaxOpt=(2.175 0.050 3.85 3.85 0.67 1.8 1.8 0.82 0.82 0.315 0.315 3.8 3.8 2.3 0.035 0.053 13)
# varMinOpt=(2.125 0.046 3.60 3.60 0.63 1.5 1.5 0.70 0.70 0.270 0.270 3.6	3.6 1.5 0.019 0.043 10)
# varType=(0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1)


varName=(psi2s_jpsi_dR pi1_pt pi2_pt pi_pi_dR pi1_eta_abs pi2_eta_abs psi2s_pt pi1_pz_abs pi2_pz_abs psi2s_pi1_dR
psi2s_pi2_dR tight_mu jpsi_eta_abs psi2s_eta_abs jpsi_mu1_dR jpsi_mu2_dR psi2s_mu1_dR psi2s_mu2_dR jpsi_mass_err
psi2s_mass_err jpsi_vtx psi2s_vtx)
varMax=(0.0228 10000 10000 0.6492 1.7472 1.7472 10000.0 10000 10000 0.2944 0.2944 100 2.159 1.5320 3.74 3.74 3.632 3.632 0.0476 0.0466 10000 10000)
varMin=(-10000 0.772 0.772 -10000 -10000 -10000 11.736 -10000 -10000 -10000 -10000 -100 -10000 -10000 -10000 -10000 -10000 -10000 -10000 -10000 -10000 -10000)
varMaxOpt=(0.0228 3.55 3.55 0.6492 1.7472 1.7472 100.0 9.0 9.0 0.2944 0.2944 100 2.159 1.5320 3.74 3.74 3.632 3.632 0.0476 0.0466 1.0 1.0)
varMinOpt=(0 0.772 0.772 0 0 0 11.736 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
varType=(0 1 1 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0) #  from cut2

################## Below is the functional part! Be careful when modifying it! ##################

# First judge weather vectors above have the same demention

size1=0;size2=0;size3=0;size4=0;size5=0;size6=0

for i in ${varName[@]}
do
	size1=$(expr $size1 + 1)
done

for i in ${varMin[@]}
do
	size2=$(expr $size2 + 1)
done

for i in ${varMax[@]}
do
	size3=$(expr $size3 + 1)
done

for i in ${varType[@]}
do
	size4=$(expr $size4 + 1)
done

for i in ${varMaxOpt[@]}
do
        size5=$(expr $size5 + 1)
done

for i in ${varMinOpt[@]}
do
        size6=$(expr $size6 + 1)
done
# Find all data files
declare -a dataFile
dataFile=$dataDir*
fileNumber=0
for i in ${dataFile[@]}
do
	fileNumber=$(expr $fileNumber + 1);
done

if [[ $size1 -eq $size2 && $size1 -eq $size3 && $size1 -eq $size4 && $size1 -eq $size5 && $size1 -eq $size6 && $fileNumber -ne 0 ]] ; then
	# register in var.h
	text=''
	cat var.h > var_$taskName.h
	for (( i=0; i<$size1; i=i+1))
	do
		text="\nRooRealVar ${varName[$i]}(\"${varName[$i]}\", \"${varName[$i]}\", ${varMin[$i]}, ${varMax[$i]});"
		sed -i -e '$a\'"${text}" var_$taskName.h
		sed -i -e '$a\'"const double ${varName[$i]}_Min = ${varMin[$i]};" var_$taskName.h
		sed -i -e '$a\'"const double ${varName[$i]}_Max = ${varMax[$i]};" var_$taskName.h
		sed -i -e '$a\'"const double ${varName[$i]}_MaxOpt = ${varMaxOpt[$i]};" var_$taskName.h
		sed -i -e '$a\'"const double ${varName[$i]}_MinOpt = ${varMinOpt[$i]};" var_$taskName.h
	done

	#register in function.h
	text=''
	sed -e 's/var.h/'"var_$taskName.h"'/' function.h > function_$taskName.h
	for ((i=0; i<$size1; i=i+1))
	do
		sed -i -e '/Add_Other_Variables_Here/i\'"    variables.add(${varName[$i]});" function_$taskName.h
	done
	sed -i -e '/Add_Other_Variables_Here/d' function_$taskName.h
	# register all .C files
	for (( i=0; i<$size1; i=i+1))
	do
		if [ ${varType[$i]} -eq 0 ]
                then
                        sed -e '3s/function.h/'"function_$taskName.h/" ParaOptMax.C > ${varName[$i]}_$taskName.C
                else
                        sed -e '3s/function.h/'"function_$taskName.h/" ParaOptMin.C > ${varName[$i]}_$taskName.C
                fi
		sed -i -e '1,$s/VarName/'"${varName[$i]}/g" ${varName[$i]}_$taskName.C
		sed -i -e 's/TaskName/'"${taskName}/" ${varName[$i]}_$taskName.C
	done
	# register Execute files
	sed -e 's/Execute/'"Execute_${taskName}/" Execute.C > Execute_${taskName}.C
	sed -i -e '/Register/a\REGISTER' Execute_${taskName}.C
	for (( i=0; i<$size1; i=i+1))
	do
		sed -i -e '/REGISTER/i\'"        name->push_back(\"${varName[$i]}_$taskName.C\");" Execute_${taskName}.C
	done
	sed -i -e '/REGISTER/d' Execute_${taskName}.C
	sed -i -e 's/function.h/'"function_${taskName}.h/"  Execute_${taskName}.C
	# register data files
	text=''
	num=$(expr $fileNumber - 1)
	for i in ${dataFile[@]}
	do
		text="${text}$(echo $i | sed -e 's:'"$dataDir::g"), "
	done
	text=${text%, } # Delete last , 
	for (( i=0; i<$size1; i=i+1))
	do
		sed -i -e '1,/Data_List/{s:Data_List:'"${text}:}"  ${varName[$i]}_$taskName.C 
        done
	# register DrawCut.C
	text=''
        num=$(expr $fileNumber - 1)
        for i in ${dataFile[@]}
        do
                text="${text}$(echo $i | sed -e 's:'"$dataDir::g"), "
        done
        text=${text%, } # Delete last ,
        sed -e '1,/Data_List/{s:Data_List:'"${text}:}" DrawCut.C > DrawCut_$taskName.C
	sed -i -e 's:DataDir:'"${dataDir}:" DrawCut_$taskName.C
	sed -i -e 's:DrawCut:'"DrawCut_${taskName}:" DrawCut_$taskName.C
	# register result and data dir 
	mkdir -p result/${taskName}_result
	for (( i=0; i<$size1; i=i+1))
        do
		sed -i -e 's:DataDir:'"${dataDir}:"  ${varName[$i]}_$taskName.C
	done
else
	if [[ $fileNumber -eq 0 ]]
	then
		echo 'No data files'
	fi
	if [[ $size1 -eq 0 || $size2 -eq 0 || $size3 -eq 0 || $size4 -eq 0 || $size5 -eq 0 || $size6 -eq 0 ]]
	then
		echo 'Some var vectors have 0 demention'
	fi
	if [[ $size1 -eq $size2 && $size1 -eq $size3 && $size1 -eq $size4 && $size1 -eq $size5 && $size1 -eq $size6 ]]
	then
		echo 'Please check'
	else
		echo 'Var vectors have different dementions!'
		echo "size1 $size1 size2 $size2 size3 $size3 size4 $size4 size5 $size5 size6 $size6"
		echo 'Please check'
	fi
fi
