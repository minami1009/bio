#ほとんどREADMEそのまま

#適当なフォルダを作る（この後入れるdatabaseが大きいので入れる先に注意）
cd '/media/member/HDPH-UT/RF2NA'

#git cloneする
git clone https://github.com/uw-ipd/RoseTTAFold2NA.git

#condaで環境構築
cd RoseTTAFold2NA
conda env create -f RF2na-linux.yml
conda activate RF2NA

#SE3Transformerのインストール
##毎回やらないとエラーになるっぽい
cd SE3Transformer
pip install --no-cache-dir -r requirements.txt
python setup.py install

#pre-trained weightsのダウンロード
cd ../network
wget https://files.ipd.uw.edu/dimaio/RF2NA_sep22.tgz
tar xvfz RF2NA_sep22.tgz
ls weights/ 
cd ..

#databaseのダウンロード
##uniref30 [46G]
wget http://wwwuser.gwdg.de/~compbiol/uniclust/2020_06/UniRef30_2020_06_hhsuite.tar.gz
mkdir -p UniRef30_2020_06
tar xfz UniRef30_2020_06_hhsuite.tar.gz -C ./UniRef30_2020_06

##BFD [272G]
wget https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
mkdir -p bfd
tar xfz bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz -C ./bfd

##structure templates (including *_a3m.ffdata, *_a3m.ffindex)
wget https://files.ipd.uw.edu/pub/RoseTTAFold/pdb100_2021Mar03.tar.gz
tar xfz pdb100_2021Mar03.tar.gz

##RNA databases
mkdir -p RNA

##Rfam [300M]
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.full_region.gz -C ./RNA
wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.cm.gz -C ./RNA

##RNAcentral [12G]
wget ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/sequences/rnacentral_species_specific_ids.fasta.gz -C ./RNA
wget ftp://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/rfam/rfam_annotations.tsv.gz -C ./RNA

##nt [151G]
cd RNA
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/
###ncbi-blast-2.x.x+ -> bin -> update_blastdb.plをRNAフォルダにコピー
update_blastdb.pl --decompress nt
cd ../example

#実行
##今のところ、RNAの.fa配列はUではなくTを使う
../run_RF2NA.sh t001_ protein.fa R:RNA.fa
