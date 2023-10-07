#!/bin/bash
# cat test.out | awk '/Bases/ { print $4 }'
# 运行脚本
# fqzcomp cpu并行效率很低, <200%. 压缩整个fastq文件，我们只抽取reads的压缩率
# fqzcomp 没有-t选项，我们默认分配16核CPU
# nohup srun -p gpu1 -N 1 -c 16 --mem-per-cpu=10G ./fqzcomp.sh > /public/home/jd_sunhui/genCompressor/LRCB/result/fqzcomp_16.out &
echo "1 设置实验参数，为了避免错误，使用绝对路径."
ResultDir="/public/home/jd_sunhui/genCompressor/LRCB/result"
Algorithm="fqzcomp"
threads=16
# 将时间戳转换为秒
function timer_reans() {
  if [[ $1 == *"."* ]]; then
    #echo "The string contains a dot. ==> m:ss"
    local min=$(echo "$1" | cut -d ':' -f 1)
    local sec=$(echo "$1" | cut -d ':' -f 2 | cut -d '.' -f 1)
    local ms=$(echo "$1" | cut -d '.' -f 2)
    #echo "Minutes: $min"
    #echo "Seconds: $sec"
    #echo "Milliseconds: $ms"
    local result=$(echo "scale=3; 60*${min}+${sec}+$ms/1000+1" | bc)
    #echo "result: $result"
    echo $result
  else
    #echo "The string does not contain a dot. ==> h:mm:ss"
    local hour=$(echo "$1" | cut -d ':' -f 1)
    local min=$(echo "$1" | cut -d ':' -f 2)
    local sec=$(echo "$1" | cut -d ':' -f 3)
    local result=$(echo "scale=3; 3600*${hour}+60*${min}+$sec+1.001" | bc)
    echo $result
  fi
}

echo "2 创建算法存储及工作目录"
mkresdir=${ResultDir}/${Algorithm}
if [ ! -d "$mkresdir" ]; then
  mkdir -p "$mkresdir"
  echo "Created directory: $directory"
else
  echo "Directory already exists: $directory"
fi

# 创建一个写入记录的VCF文件
echo "DataSet, CompressedFileSize (B),CompressionRatio (bits/base),CompressionTime (S),CompressionMemory (KB),DeCompressionTime (S),DeCompressionMemory (KB)" > ${mkresdir}/${Algorithm}_${threads}.csv
cd ${mkresdir} # 切换到算法工作目录, colord输出的单位为B

echo "3 执行算法压缩及解压缩操作"
F_NAME=$(cat /public/home/jd_sunhui/genCompressor/LRCB/script/F_Name.txt | tr -d '\r')
for SourceDataDir in $F_NAME; do
  echo "-------------------------------------------------------------------------------------------"
  echo "SourceDataDir : ${SourceDataDir}"
  FileBaseName=$(basename ${SourceDataDir})

  echo "3.1 将数据拷贝至工作目录下" # 避免脏数据
  cp ${SourceDataDir}.fastq ${mkresdir}
  cp ${SourceDataDir}.reads ${mkresdir}

  echo "3.2 调用${Algorithm}进行文件压缩操作"
  echo "compression..."
  (/bin/time -v -p /public/home/jd_sunhui/genCompressor/LRCB/fqzcomp/fqzcomp ${FileBaseName}.fastq ${FileBaseName}.fqzcomp) >${FileBaseName}_${threads}_com.log 2>&1
  echo "统计压缩信息"
  CompressedFileSize=$(grep "Bases" ${FileBaseName}_${threads}_com.log | awk '{print $4}') # 单位为B
  CompressionTime=$(cat ${FileBaseName}_${threads}_com.log | grep -o 'Elapsed (wall clock) time (h:mm:ss or m:ss):.*' | awk '{print $8}')
  CompressionMemory=$(cat ${FileBaseName}_${threads}_com.log | grep -o 'Maximum resident set size.*' | grep -o '[0-9]*')
  SourceFileSize=$(ls -lah --block-size=1 ${FileBaseName}.reads | awk '/^[-d]/ {print $5}') #以字节为单位显示原始文件大小
  CompressionRatio=$(echo "scale=3; 8*${CompressedFileSize}/${SourceFileSize}" | bc)
  echo "CompressedFileSize : ${CompressedFileSize} B"
  echo "CompressionTime : ${CompressionTime} h:mm:ss or m:ss"
  echo "CompressionTime : $(timer_reans $CompressionTime) S"
  echo "CompressionMemory : ${CompressionMemory} KB"
  echo "SourceFileSize : ${SourceFileSize} B"
  echo "CompressionRatio : ${CompressionRatio} bits/base"

  echo "3.3 调用${Algorithm}进行文件解压缩操作"
  echo "de-compression..."
  (/bin/time -v -p /public/home/jd_sunhui/genCompressor/LRCB/fqzcomp/fqzcomp -X -d ${FileBaseName}.fqzcomp ${FileBaseName}.fqzcomp.fastq) >${FileBaseName}_${threads}_decom.log 2>&1
  echo "统计压缩信息"
  DeCompressionTime=$(cat ${FileBaseName}_${threads}_decom.log | grep -o 'Elapsed (wall clock) time (h:mm:ss or m:ss):.*' | awk '{print $8}')
  DeCompressionMemory=$(cat ${FileBaseName}_${threads}_decom.log | grep -o 'Maximum resident set size.*' | grep -o '[0-9]*')
  echo "DeCompressionTime : ${DeCompressionTime} h:mm:ss or m:ss"
  echo "DeCompressionTime : $(timer_reans $DeCompressionTime) S"
  echo "DeCompressionMemory : ${DeCompressionMemory} KB"

  echo "3.4 将结果存储在一个新的文件"
  echo "CompressedFileSize (B)  : ${CompressedFileSize}" >${FileBaseName}_${threads}.log
  echo "CompressionRatio (bits/base): ${CompressionRatio}" >>${FileBaseName}_${threads}.log
  echo "CompressionTime (S)     : $(timer_reans $CompressionTime)" >>${FileBaseName}_${threads}.log
  echo "CompressionMemory (KB)  : ${CompressionMemory}" >>${FileBaseName}_${threads}.log
  echo "DeCompressionTime (S)   : $(timer_reans $DeCompressionTime)" >>${FileBaseName}_${threads}.log
  echo "DeCompressionMemory (KB): ${DeCompressionMemory}" >>${FileBaseName}_${threads}.log

  echo "3.5 清除脏文件"
  cat ${FileBaseName}_${threads}_decom.log
  head -c 200 ${FileBaseName}.fqzcomp.fastq
  head -c 200 ${FileBaseName}.fastq
  rm -rf ${FileBaseName}.reads
  rm -rf ${FileBaseName}.fastq
  rm -rf ${FileBaseName}.fqzcomp
  rm -rf ${FileBaseName}.fqzcomp.fastq

  echo "3.6 将结果存储在CSV文件"
  echo "${FileBaseName}, ${CompressedFileSize}, ${CompressionRatio}, $(timer_reans $CompressionTime), ${CompressionMemory}, $(timer_reans $DeCompressionTime), ${DeCompressionMemory}" >> ${Algorithm}_${threads}.csv
done



exit
