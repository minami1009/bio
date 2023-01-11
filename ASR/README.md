1. 相同塩基・タンパク質配列の取得（BLAST）：percent identityが30〜90％を取得している
2. cd-hitで相同性の高い配列を削除（90％以上は削除している）
3. MAFFT（https://mafft.cbrc.jp/alignment/server/ ）でmultiple sequence alignment
4. TrimAlでトリミング（した後に目視で確認する）
5. IQ-treeまたはRAxMLで系統樹推定
