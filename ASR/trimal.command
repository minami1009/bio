#参考：https://kazumaxneo.hatenablog.com/entry/2017/09/16/101719

conda install -c bioconda trimal 
trimal -in input.fasta -out trimal-output.fasta -htmlout output.html -gt 0.9 -cons 60
