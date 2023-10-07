import sys
import os

fastq_file = sys.argv[1]
file_name_without_extension = os.path.splitext(fastq_file)[0]
fasta_file = file_name_without_extension + ".fasta"

with open(fastq_file, "r") as fastq, open(fasta_file, "w") as fasta:
    line_count = 0
    for line in fastq:
        line_count += 1
        if line_count % 4 == 2:
            line = line.strip()  # 去除空格和换行符
            fasta.write(line)

    fasta.write("\n")
    fasta.seek(0)  # 移动文件指针到文件开头
    fasta.write(">"+ "\n")  # 在第一行开头写入">"符号

print("FASTA文件已生成:", fasta_file)