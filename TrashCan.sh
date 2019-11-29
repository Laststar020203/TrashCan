#! /bin/bash


function getData (){ #안에서 gv_data를 찾아줍니다.

        local gv_data="${1}"
        if [ -e ${gv_data} ];then
                DATA=($(cat ${gv_data}))
        fi

}


function showInfo { #sh나 txi:t파일을 주면 모두 보여준다. 이름 값만 아닌 경로를 주어도 처리

        local path="${1%/*}"
        local fileName="${1##*/}"
        if [[ "${fileName##*/}" != "."* ]];then
                local fileName=".${fileName%.*}.txt"
        fi
        local finish="${path}/${fileName}"
        getData ${finish}
        if [ ${#DATA[@]} -eq 4 ];then
                        local originName=${DATA[0]}
                        local deleteDate=${DATA[1]}
                        local orginPath=${DATA[2]}
                        if [ -e ${DATA[3]} ];then
                                        echo "${originName}    ${deleteDate}    ${orginPath}"
                        else
                                        rm ${1}
                        fi
        fi

}


function allShowInfo {
        for entry in ${@}
        do
                showInfo ${entry}
        done
}

function findJunkFileList { # 인자 값이 있으면 인자 값 파일명대로 찾고 없으면 전체를 찾음
	
	if [ ${#} -eq 1 ];then
		local fileName=${1%.*}
		local fileEx="${1##*.}"
		fileList=($(find ${trashCan} -name "${fileName}*" -and -name "*.${fileEx}")) #gv파일을 안찾아도 무관 showinfo에서 처리르 해줄거기 때문
	else
		fileList=($(find ${trashCan} -name "*.txt"))
	fi
	
}


function restore { #1.gvFile 2.originFileName
        local fileName=${1##*/}
        rename "${fileName}" "${2}" ${1} #이름 바꾸기
        local gvFile="${trashCan}/.${fileName%.*}.txt"
        getData ${gvFile}        
		mv "${trashCan}/${2}" ${DATA[2]} #원위치로 복원
        rm "${gvFile}"
}



function destroy { #1.gvFile
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
        if [  -e ${filePath} ]  ||  [ ! -e ${logFile}  ];then
        mv ${newPath} "${trashCan}/${file_fullName}"
        mv "${trashCan}/${file_fullName}" ${filePath}
                if [ -e ${logFile} ];then
                        rm ${logFile}
                fi
        echo "Fail.. :["
        else
        echo "Delete"
        fi
}



function restoreRoutin {

        findJunkFileList ${1}
        local gvData=
        if [ ${#fileList[@]} -eq 0 ];then:
                echo "file is not exist"
        elif [ ${#fileList[@]} -eq 1 ];then
                restore ${fileList[0]} ${1}
                local gvData=${fileList[0]}
        else
                echo "Please enter the number to restore from the list"
                                allShowInfo ${fileList[@]}
                echo -e "input : c "
                read word
                if [ ${word} -le ${#fileList[@]} ];then
                        local gvData=${fileList[ ${word} - 1 ]}
                        restore ${gvData} ${1}
                fi
        fi

        if [ ! -e ${gvData}  ];then
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
         
               findJunkFileList ${1}

                local gvData=
                if [ ${#fileList[@]} -eq 0 ];then
                        echo "File is not exist"
                elif [ ${#fileList[@]} -eq 1 ];then
                        local gvData=${fileList[0]}
                        destroy ${fileList[0]}
                else
                        echo "Please enter the number to delete from the list"
						allShowInfo ${fileList[@]}
                        echo -e "input : "
                        read word
                        if [ ${word} -le ${#fileList[@]} ];then
                                local gvData=${fileList[ ${word} - 1 ] }
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
                                restoreRoutin "${2}"
                        fi
                ;;
                "ls")
                        allShowInfo $(find ${trashCan} -name ".*" -and -name "*.txt")
                ;;
                "help")
						
                ;;
                esac
        fi
}

main $@


