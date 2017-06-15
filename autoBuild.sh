#!/bin/bash
# Author PY
# 用法示例 sh autoBuild.sh /Users/xxx/Desktop/xxx/xxx.xcodeproj  [SchemeName] xxx.plist

#获取输入参数 工程地址 场景名字 plist地址
PROJPATH=$1
SCHEMENAME=$2
PLISTPATH=$3

echo "~~~~~~~~~~~~~~~~开始执行脚本~~~~~~~~~~~~~~~~"

#获取当前时间创建ipa文件夹
beginTime=`date +%s`
DATE=`date +%Y%m%d_%H%M`
SOURCEPATH=$( cd "$( dirname %0 )" &&pwd )
IPAPATH=$SOURCEPATH/AutoBuildIPA/$DATE
ARCHIVEPATH=$IPAPATH/$SCHEMENAME.xcarchive

echo "~~~~~~~~~~~~~~~~开始编译~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~开始清理~~~~~~~~~~~~~~~~"
#清理
xcodebuild clean -project $PROJPATH -configuration Release -alltargets

echo "~~~~~~~~~~~~~~~~开始构建~~~~~~~~~~~~~~~~"
# 编译
xcodebuild archive -project $PROJPATH -scheme $SCHEMENAME -configuration Release -archivePath $ARCHIVEPATH

echo "~~~~~~~~~~~~~~~~检查是否构建成功~~~~~~~~~~~~~~~~~~~"
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$ARCHIVEPATH" ]
then
echo "构建成功......"
else
echo "构建失败......"
rm -rf $IPAPATH
exit 1
fi
endTime=`date +%s`
ArchiveTime="构建时间$[ endTime - beginTime ]秒"

echo "~~~~~~~~~~~~~~~~导出ipa~~~~~~~~~~~~~~~~~~~"

#导出ipa
beginTime=`date +%s`

xcodebuild -exportArchive -archivePath $ARCHIVEPATH -exportOptionsPlist $PLISTPATH -exportPath $IPAPATH CODE_SIGN_IDENTITY="iPhone Distribution: iSoftStone Information Technology Co.,Ltd. (583CAJEQH8)"  PROVISIONING_PROFILE="88b0f995-939a-42a8-bac4-9ef6b08cff97"

echo "~~~~~~~~~~~~~~~~检查是否成功导出ipa~~~~~~~~~~~~~~~~~~~"
if [ -f "${IPAPATH}/${SCHEMENAME}.ipa" ]
then
echo "导出ipa成功......"
else
echo "导出ipa失败......"
# 结束时间
endTime=`date +%s`
echo "$ArchiveTime"
echo "导出ipa时间$[ endTime - beginTime ]秒"
exit 1
fi

endTime=`date +%s`
ExportTime="导出ipa时间$[ endTime - beginTime ]秒"

        
echo "~~~~~~~~~~~~~~~~上传fir~~~~~~~~~~~~~~~~~~~"
#上传
fir i $IPAPATH/$SCHEMENAME.ipa

#打开
open $IPAPATH


echo "~~~~~~~~~~~~~~~~配置信息~~~~~~~~~~~~~~~~~~~"
echo "开始执行脚本时间: ${DATE}"
echo "编译模式: ${CONFIGURATION_TARGET}"
echo "导出ipa配置: ${PLISTPATH}"
echo "打包文件路径: ${ARCHIVEPATH}"
echo "导出ipa路径: ${IPAPATH}"

echo "$ArchiveTime"
echo "$ExportTime"

exit 1
