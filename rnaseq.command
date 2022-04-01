#パッケージのインストール
conda install -c bioconda trimmomatic
conda install -c bioconda fastqc

#アダプター配列のトリミングとQC
#アダプター配列ファイルへのシンボリックリンクを作成
ln -s /Users/minami/opt/anaconda3/share/trimmomatic-0.39-2/adapters/TruSeq3-SE.fa

#trimmomatic
FILES=(SRR111111 SRR111112 SRR111113 SRR111114)
for file in ${FILES[@]}; do \
trimmomatic PE -threads 10 -phred33 -trimlog trimlog_${file}.txt -summary summary_${file}.txt ${file}_1.fq.gz ${file}_2.fq.gz ${file}_trim_pair_1.fastq.gz ${file}_trim_unpair_1.fastq.gz ${file}_trim_pair_2.fastq.gz ${file}_trim_unpair_2.fastq.gz ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:30 \
done

#fastqc
mkdir fastqc
for file in ${FILES[@]}; do \
fastqc -t 10 --nogroup -o fastqc -f fastq {file}_trim_pair_1.fastq.gz ${file}_trim_pair_2.fastq.gz \
done

#マッピングとソーティング
#パッケージのインストール
conda install -c bioconda hisat2
conda install -c bioconda samtools

#シンボリックリンクを作成
cd /home/member/anaconda3/bin/../lib
ln -s libcrypto.so.1.1 libcrypto.so.1.0.0

for file in ${FILES[@]};do \
hisat2 -p 16 -t -x grcm38/genome -1 ${file}_trim_pair_1.fastq.gz -2 ${file}_trim_pair_2.fastq.gz -S ${file}.sam \
done

#samtoolsを用いてsamファイルをソート済bamファイルに変換
for file in ${FILES[@]};do \
samtools sort -@ 16 -O bam -o ${file}_sort.bam ${file}.sam \
done

#ソート済bamファイルのindexを作成
for file in ${FILES[@]};do \
samtools index ${file}_sort.bam \
done

#stringtieを用いた発現量の推定
#ballgown用のオプションを指定
for file in ${FILES[@]};do \
stringtie ${file}_sort.bam -e -B -G gencode.vM28.annotation.gtf -o ballgown/${file}/${file}.gtf \
done
