#!/bin/bash
#SBATCH -J lstm_real
#SBATCH -p A30
#SBATCH -w gpu7
#SBATCH -N 1
#SBATCH -c 16
#SBATCH -o lstm_real.out
#SBATCH -e lstm_real.err
cd  $SLURM_SUBMIT_DIR
#source activate a30
echo "1 设置实验参数，为了避免错误，使用绝对路径."
D1="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR3077524"
D2="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR11274574"
D3="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25685106"
D4="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR3077535"
D5="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR2708436"
D6="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR2708427"
D7="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR1204468"
D8="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/yeast_filtered"
D9="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR11011595"
D10="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25689478"
D11="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/bc1019"
D12="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25503121"
D13="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR4179766"
D14="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25503117"
D15="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25743051"
D16="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR4179765"
D17="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/bc1099"
D18="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25655962"
D19="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25601474"
D20="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR12121586"
D21="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25731491"
D22="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR12121585"
D23="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25555001"
D24="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25750558"
D25="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25750949"
D26="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR25647249"
D27="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR23822210"
D28="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/ERR5396170"
D29="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/athal_filtered"
D30="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR11292120"
D31="/public/home/jd_mhd/work/03-Compressor_review/data/new_real_data/SRR10382244"
ResultDir="/public/home/jd_mhd/work/03-Compressor_review/data/result"
Algorithm="lstm"
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
cd ${mkresdir} # 切换到算法工作目录

echo "3 执行算法压缩及解压缩操作"
for SourceDataDir in $D1 $D2 $D3 $D4 $D5 $D6 $D7 $D8 $D9 $D10 $D11 $D12 $D13 $D14 $D15 $D16 $D17 $D18 $D19 $D20 $D21 $D22 $D23 $D24 $D25 $D26 $D27 $D28 $D29 $D30 $D31; do
  echo "-------------------------------------------------------------------------------------------"
  echo "SourceDataDir : ${SourceDataDir}"
  FileBaseName=$(basename ${SourceDataDir})

  echo "3.1 将数据拷贝至工作目录下" # 避免脏数据
  cp ${SourceDataDir}.reads ${mkresdir}

  echo "3.2 调用${Algorithm}进行文件压缩操作"
  echo "compression..."
  (/bin/time -v -p lstm-compress -c ${FileBaseName}.reads ${FileBaseName}.lstm) >${FileBaseName}_${threads}_com.log 2>&1
  echo "统计压缩信息"
  CompressedFileSize=$(ls -lah --block-size=1 ${FileBaseName}.lstm | awk '/^[-d]/ {print $5}')
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
  (/bin/time -v -p lstm-compress -d ${FileBaseName}.lstm ${FileBaseName}.lstm.reads) >${FileBaseName}_${threads}_decom.log 2>&1
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

  echo "3.5 判断解压前后数据一致性"
  if cmp -s ${FileBaseName}.reads ${FileBaseName}.lstm.reads; then
    echo "The file ${FileBaseName}.lstm.reads is the same as  ${FileBaseName}.reads"
  else
    echo "The file ${FileBaseName}.lstm.reads is different from ${FileBaseName}.reads"
  fi

  rm -rf ${FileBaseName}.reads
  rm -rf ${FileBaseName}.lstm
  rm -rf ${FileBaseName}.lstm.reads

  echo "3.6 将结果存储在CSV文件"
  echo "${FileBaseName}, ${CompressedFileSize}, ${CompressionRatio}, $(timer_reans $CompressionTime), ${CompressionMemory}, $(timer_reans $DeCompressionTime), ${DeCompressionMemory}" >> ${Algorithm}_${threads}.csv
done