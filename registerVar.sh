#!/bin/bash
# Please first run this script to generate files for cut optimization
# Substitute variables below to what you want 

# Task information
taskName='cutOpt7'
dataDir="/home/qjk/JPsiX3872/Cut9/"

# Variables
declare -a varName 
declare -a varMax # Range for primary cut
declare -a varMin 
declare -a varMaxOpt # Range for cut to vary
declare -a varMinOpt
declare -a varType # Variable for deciding varying upper bundary or lower bundary. 0 for upper and 1 for lower

varName=(jpsi2_eta_abs jpsi2_massErr mu3_eta_abs mu4_eta_abs jpsi2_psi2s_dR)
varMax=(10000 10000 10000 10000 10000)
varMin=(-10000 -10000 -10000 -10000 -10000)
varMaxOpt=(2.7 0.068 0 0 5.5)
varMinOpt=(2.1 0.04 0 0 3.1)
varType=(0 0 0 0 0) # mu eta is not used but have to be included for correctly loading data, please remove them in Execute.C

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
