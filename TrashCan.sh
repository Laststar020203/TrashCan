#! /bin/bash

trashCan=""

DATA=
function getData (){ #안에서 gv_data를 찾아줍니다.

        local gv_data="${1}"
        if [ -e ${gv_data} ];then
                DATA=($(cat ${gv_data}))
        fi

}



function showInfo { #1. 디렉토리 or list or 명령어
        for entry in ${@} #$(find /home/gold/test/trashCan) #fileList
        do
                getData ${entry}
                if [ ${#DATA[@]} -eq 4 ];then
                        local originName=${DATA[0]}
                        local deleteDate=${DATA[1]}
                        local orginPath=${DATA[2]}
                        if [ -e ${DATA[3]} ];then
                                echo "${originName}    ${deleteDate}    ${orginPath}"
                        else
                                rm ${entry}
                        fi
                fi
        done
}



function restore { #1.gvFile 2.originFileName
        mv "${1}" "${trashCan}/${2}" #이름 바꾸기
        getData fileList[0]
        mv "${trashCan}/${2}" DATA[2] #원위치로 복원
        rm "${trashCan}/${2%.*}.txt"
}

function destory { #1.gvFile
        rm "${1}"
        local fileName="${1##*/}"a
        rm "${trashCan}/.${fileName%.*}.txt"
}



function deleteRoutin {
        #만약 확장자가 없으면

        if [ ! -e ${1} ];then
                        echo "file is not exist"
        else
                        local filePath=$(readlink -e ${1})
                        local file_fullName="$(basename ${filePath})"
                        local fileName="${file_fullName%.*}"
                        if [[ ! ${file_fullName} == *"."* ]];then
                                        echo "file don't have extension!"
                        else
                                        local extension="${file_fullName##*.}"
                                        local date=`date +%Y%m%d%H%M%s%3N`
                                        local newName="${fileName}-${date}"
                                        local newPath="$(dirname ${filePath})/${newName}.${extension}"
                        #       rename -n  ${fileName} ${newName} ${filepath}
                                        mv $filePath $newPath
                                        mv "${newPath}" "${trashCan}"
                                        local logFile="${trashCan}/.${newName}.txt"
                                        touch "${logFile}"
                                        #orginName fileName orginPath
                                        echo "${file_fullName}" >> "${logFile}"
                                        echo "${date}" >> "${logFile}"
                                        echo "${filePath}" >> "${logFile}"
                                        echo "${trashCan}/${newName}.${extension}" >> "${logFile}"
                        fi
        fi
        if [ ! -e ${filePath} ];then
        echo "Delete!"
        else
        echo "Fail :["
        fi
}




function restoreRoutin {

        local fileList=getMatchFiles ${1}
        local gvData=""

        if [ fileList[@] -eq 0 ];then
                echo "file is not exist"
        elif [ fileList[@] -eq 1 ];then
                restore fileList[0] ${1}
                local gvData=fileList[0]
        else
                echo "Please enter the number to restore from the list"
                showInfo fileList
                echo -e "input : c "
                read word
                if [ ${word} -le fileList[@] ];then
                restore fileList[${word}] ${1}
                local gvData=fileList[${word}]
                fi
        fi

        if [ [ -z ${gvData} ] || [ -e ${gvData} ] ];then
                echo "Success :]"
        else
                echo "Fail :["
        fi

}


function clearRoutin {

        case ${1} in
        "all")
                for entry in $(find "${trashCan}" -not -path ${trashCan})  #선택된 디레토리를 제외함
                do
                        rm "${entry}"
                done
                echo "Clear!"
        ;;
        *)
                getMatchFiles ${1}

                local fileName="${1%.*}"
                local fileEx="${1##*.}"

                local fileList=($(find ${trashCan} -name "${fileName}*" -and -name "*.${fileEx}"))


                local gvData=
                if [ ${#fileList[@]} -eq 0 ];then
                        echo "File is not exist"
                elif [ ${#fileList[@]} -eq 1 ];then
                        local gvData=${fileList[0]}
                        destory ${fileList[0]}
                else
                        echo "Please enter the number to delete from the list"
                        for entry in ${fileList[@]}
                        do
                                local mapping=${entry##*/}
                                showInfo "${trashCan}/.${mapping%.*}.txt"
                        done
                        echo -e "input : "
                        read word
                        if [ ${word} -le ${#fileList[@]} ];then
                                local gvData=${fileList[ ${word} ] }
                                destroy ${gvData}

                        fi
                fi
                if [ ! -e ${gvData} ];then
                        echo "Clear!"
                else
                        echo "Fail :["
                fi
        ;;
        esac
}

function main {

        trashCan=/home/gold/test/trashCan
        trashCan_log=/home/gold/test/trashCan/trashCan_log.txt
        if [ ! -e ${trashCan} ];then
                mkdir /home/gold/test/trashCan
                touch ${trashCan}/trashCan_log.txt
        fi
        if [ $# -lt 1 ];then
                echo "incorrect arguent : long query "
        else
                case ${1} in
                "delete")
                        if [ $# -eq 2 ];then
                                deleteRoutin "${2}"
                        else
                                echo "incorrect argument : delete query ned argument 2 "
                        fi
                ;;
                "clear")
                        if [ $# -eq 2 ];then
                                clearRoutin "${2}"
                        fi
                ;;
                "restore")
                        if [ $# -eq 2 ];then
                                deleteRoutin "${2}"
                        fi
                ;;
                "ls")
                        showInfo $(find ${trashCan} -name "*.txt")
                ;;
                "help")
                ;;
                esac
        fi
}

main $@

