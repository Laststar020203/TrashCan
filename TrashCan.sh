#! /bin/bash

trashCan=""

function getMatchFiles {

        fileName="${1%.*}"
        fileEx="${1##*.}"


        fileList=()
        gvData=""

        for entry in $(find ${trashCan} -name "${fileName}*" -and -name "*.${fileEx}")
        do
                fileList+=("${entry}")
        done

        return fileList

}

function getData { #안에서 gv_data를 찾아줍니다.

        gv_data="${trashCan}/${1%.*}.txt"
        if [ -e ${gv_data} ];then
                DATA=()
                while read st_d; do
                        DATA+="${st_d}"
                done < ${1}
                return DATA
        fi

}

function allListShow { #1. 디렉토리 or list or 명령어
        for entry in ${@} #$(find /home/gold/test/trashCan) #fileList
        do
                dataes=getData ${entry}
                if [ ${dataes[@]} -eq 3 ];then
                        originName=${dataes[0]}
                        deleteDate=${dataes[1]}
                        orginPath=${dataes[2]}
                        if [ -e ${dataes[3]} ];then
                                echo "${orginName}      ${deleteDate}   ${orginPath}"
                        else
                                rm ${entry}
                        fi
                fi
        done
}

function restore { #1.gvFile 2.originFileName
        mv "${1}" "${trashCan}/${2}" #이름 바꾸기
        dataes=getData fileList[0]
        mv "${trashCan}/${2}" dataes[2] #원위치로 복원
        rm "${trashCan}/${2%.*}.txt"
}

function destory { #1.gvFile
        rm "${trashCan}/${1}"
        rm "${trashCan}/${1%.*}.txt"
}

function deleteRoutin {
        #만약 확장자가 없으면

        if [ ! -e ${1} ];then
                        echo "file is not exist"
        else
                        filePath=$(readlink -e ${1})
                        file_fullName="$(basename ${filePath})"
                        fileName="${file_fullName%.*}"

                        if [ [ ${file_fullName} =~ "." ] -eq 1 ];then
                                        echo "file don't have extension!"
                        else
                                        extension="${file_fullName##*.}"
                                        date=`date +%Y%m%d%H%M`
                                        newName="${fileName}-${date}"
                                        newPath="$(dirname ${filepath})/${newName}.${extension}"
                        #       rename -n  ${fileName} ${newName} ${filepath}
                                        mv $filepath $newPath
                                        mv "${newPath}" "${trashCan}"
                                        logFile="${trashCan}/.${newName}.txt"
                                        touch "${logFile}"
                                        #orginName fileName orginPath
                                        echo "${file_fullName}" >> "${logFile}"
                                        echo "${date}" >> "${logFile}"
                                        echo "${filePath}" >> "${logFile}"
                                        echo "${newName}.${extension}" >> "${logFile}"
                        fi
        fi
        if [ ! -e ${filepath} ];then
        echo "Delete!"
        else
        echo "Fail :["
        fi
}

function restoreRoutin {

        fileList=getMatchFiles ${1}
        gvData=""

        if [ fileList[@] -eq 0 ];then
                echo "file is not exist"
        elif [ fileList[@] -eq 1 ];then

                restore fileList[0] ${1}
                gvData=fileList[0]
        else
                echo "Please enter the number to restore from the list"
                allListShow fileList
                echo -e "input : c "
                read word
                if [ ${word} -le fileList[@] ];then
                restore fileList[${word}] ${1}
                gvData=fileList[${word}]
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
                for entry in $(find ${trashCan} -name "*.txt")
                do
                        rm "${entry}"
                        echo "Clear!"
                done
        ;;
        *)
                fileList=getMatchFiles ${1}
                gvData=""
                if [ fileList[@] -eq 0 ];then
                        echo "File is not exist"
                elif [ fileList[@] -eq 1 ];then
                        getData=fileList[0]
                        destory fileList[0]
                else
                        echo "Please enter the number to delete from the list"
                        allListShow fileList
                        echo -e "input : c "
                        read word
                        if [ ${word} -le fileList[@] ];then
                                gvData=fileList[${word}]
                                destory fileList[${word}]
                        fi
                fi
                           
                if [ [ -z ${gvData} ] || [ -e ${gvData} ] ];then
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
                        if [ $# -eq 3];then
                                clearRoutin "${2}"
                        fi
                ;;
                "restore")
                        if [ $# -eq 2 ];then
                                deleteRoutin "${2}"
                        fi
                ;;
                "ls")
                        allListShow $(find ${trashCan} -name "*.txt")
                ;;
                "help")
                ;;
                esac
        fi
}

main $@

