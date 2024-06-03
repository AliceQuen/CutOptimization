#!/bin/bash
# Please first run this script to generate files for cut optimization

############################### Configuration #############################
taskName='cutOpt7' # Name of this task
jobScriptDir='/home/qjk/JPsiX3872/CutOptimization/JobScripts' # Job script Directory, DO NOT INCLUDE last '/', force to re-create a jobScriptDir/taskName 
dataDir="/home/qjk/JPsiX3872/Cut9" # Data file Directory, DO NOT INCLUDE last '/'
var_OUT='VarList.out' # VarList.out file
Mode='1' # Mode of running, 0:Generate VarList.out File templete, 1:Generate job scripts
Discription=' Test job' # Job discription, will be saved in jobScriptDir as .md file
###########################################################################
# Variables

############### Below is the functional part! Be careful when modifying it! ################
if [ $Mode -ne 1 ]
then
	echo -e "--- Description ---\nVarName/CutMin/CutMax/OptMax/OptMin/Mode\n" > VarList.out
	# CutMin/Max is pre-cut range and OptMin/Max is cut option varying range 
	# Mode = 0 for varying Maximum and 1 for varying Minimun
	return
fi
jobScriptDir=${jobScriptDir}/${taskName}
rm -rf ${jobScriptDir}
mkdir -p ${jobScriptDir}
echo -e "${Discription}\nConfiguration\n${taskName}\njobScriptDir\ndataDir\nvar_OUT" > ${jobScriptDir}/${taskName}_README.md
# Find all data files
declare -a dataFile
dataFile="${dataDir}/*"
fileNumber=0
for i in ${dataFile[@]}
do
	fileNumber=$(expr $fileNumber + 1);
done

# register in var.h
text=''
cat var.h > ${jobScriptDir}/var_$taskName.h
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
		varMin=$(echo $rows | awk 'BEGIN{FS="/"} {print $2}')
		varMax=$(echo $rows | awk 'BEGIN{FS="/"} {print $3}')
		varMinOpt=$(echo $rows | awk 'BEGIN{FS="/"} {print $4}')
		varMaxOpt=$(echo $rows | awk 'BEGIN{FS="/"} {print $5}')
		text="\nRooRealVar ${varName}(\"${varName}\", \"${varName}\", ${varMin}, ${varMax});"
		sed -i -e '$a\'"${text}" ${jobScriptDir}/var_$taskName.h
		sed -i -e '$a\'"const double ${varName}_Min = ${varMin};" ${jobScriptDir}/var_$taskName.h
		sed -i -e '$a\'"const double ${varName}_Max = ${varMax};" ${jobScriptDir}/var_$taskName.h
		sed -i -e '$a\'"const double ${varName}_MaxOpt = ${varMaxOpt};" ${jobScriptDir}/var_$taskName.h
		sed -i -e '$a\'"const double ${varName}_MinOpt = ${varMinOpt};" ${jobScriptDir}/var_$taskName.h
	fi
done
#register in function.h
text=''
sed -e 's:var.h:'"var_${taskName}.h:g" function.h > ${jobScriptDir}/function_$taskName.h
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
		sed -i -e '/Add_Other_Variables_Here/i\'"    variables.add(${varName});" ${jobScriptDir}/function_$taskName.h
	fi
done
sed -i -e '/Add_Other_Variables_Here/d' ${jobScriptDir}/function_$taskName.h
# register all .C files
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
       		varMin=$(echo $rows | awk 'BEGIN{FS="/"} {print $2}')
    		varMax=$(echo $rows | awk 'BEGIN{FS="/"} {print $3}')
		varMimOpt=$(echo $rows | awk 'BEGIN{FS="/"} {print $4}')
	   	varMaxOpt=$(echo $rows | awk 'BEGIN{FS="/"} {print $5}')
		varType=$(echo $rows | awk 'BEGIN{FS="/"} {print $6}')
		if [[ ${varType} -eq 0 ]]
		then
			sed -e '3s/function.h/'"function_$taskName.h/" ParaOptMax.C > ${jobScriptDir}/${varName}_$taskName.C
		else
			sed -e '3s/function.h/'"function_$taskName.h/" ParaOptMin.C > ${jobScriptDir}/${varName}_$taskName.C
		fi
		sed -i -e '1,$s/VarName/'"${varName}/g" ${jobScriptDir}/${varName}_$taskName.C
		sed -i -e 's/TaskName/'"${taskName}/" ${jobScriptDir}/${varName}_$taskName.C
	fi
done
# register Execute files
sed -e 's/Execute/'"Execute_${taskName}/" Execute.C > ${jobScriptDir}/Execute_${taskName}.C
sed -i -e '/Register/a\REGISTER' ${jobScriptDir}/Execute_${taskName}.C
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
		sed -i -e '/REGISTER/i\'"        name->push_back(\"${varName}_$taskName.C\");" ${jobScriptDir}/Execute_${taskName}.C
	fi
done
sed -i -e '/REGISTER/d' ${jobScriptDir}/Execute_${taskName}.C
sed -i -e 's/function.h/'"function_${taskName}.h/"  ${jobScriptDir}/Execute_${taskName}.C
# register data files
text=''
num=$(expr $fileNumber - 1)
for i in ${dataFile[@]}
do
	text="${text}$(echo $i | sed -e 's:'"${dataDir}/::g"), "
done
text=${text%, } # Delete last , 
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then 
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
		sed -i -e '1,/Data_List/{s:Data_List:'"${text}:}"  ${jobScriptDir}/${varName}_$taskName.C 
	fi
done
# register DrawCut.C
text=''
num=$(expr $fileNumber - 1)
for i in ${dataFile[@]}
do
	text="${text}$(echo $i | sed -e 's:'"${dataDir}/::g"), "
done
text=${text%, } # Delete last ,
sed -e '1,/Data_List/{s:Data_List:'"${text}:}" DrawCut.C > ${jobScriptDir}/DrawCut_$taskName.C
sed -i -e 's:DataDir:'"${dataDir}/:" ${jobScriptDir}/DrawCut_$taskName.C
sed -i -e 's:DrawCut:'"DrawCut_${taskName}:" ${jobScriptDir}/DrawCut_$taskName.C
# register result and data dir 
mkdir -p ${jobScriptDir}/result/${taskName}_result
cat ${var_OUT} | while read rows
do
	if [[ $rows =~ ---.*--- ]]
	then
		sleep 0.001
	else
		varName=$(echo $rows | awk 'BEGIN{FS="/"} {print $1}')
		sed -i -e 's:DataDir:'"${dataDir}/:"  ${jobScriptDir}/${varName}_$taskName.C
	fi
done
