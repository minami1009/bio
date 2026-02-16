#!/bin/bash

#テンプレートにするPDBファイルの名前
#複数一気に動かしたいときはfiles=("rec01" "rec02")などと指定
files=("rec01")
gmx="/home/minami/md/gromacs/2023.2/bin/gmx"

for fname in "${files[@]}"; do
  #3連で動かす想定のためin 1 2 3としている
  for i in 1 2 3; do
    workdir="${fname}_${i}"
    echo "Processing replicate $i for $fname in $workdir..."

    mkdir -p "$workdir"
    cd "$workdir" || exit 1

    #水分子を除去する（結晶構造想定）。AlphaFold構造をテンプレートとするならここはなくても良い
    grep -v HOH "../${fname}.pdb" > "${fname}_clean.pdb"
    
    #力場を付与（RNAやDNAなど核酸複合体の想定。目的に応じて数字を設定する）
    echo "6" | $gmx pdb2gmx -f "${fname}_clean.pdb" -o "${fname}_processed.gro" -water spce -ignh
    
    #分子を箱に入れて水で満たす
    $gmx editconf -f "${fname}_processed.gro" -o "${fname}_newbox.gro" -c -d 1.0 -bt cubic
    $gmx solvate -cp "${fname}_newbox.gro" -cs spc216.gro -o "${fname}_solv.gro" -p topol.top
    
    #水(SOL)の一部をイオンに変える。SOLが14であるかどうかは先に確認する。濃度は0.15 MのNaCl
    $gmx grompp -f ../ions.mdp -c "${fname}_solv.gro" -p topol.top -o ions.tpr
    echo "14" | $gmx genion -s ions.tpr -o "${fname}_solv_ions.gro" -p topol.top -pname NA -nname CL -conc 0.15 -neutral

    #エネルギー最小化
    $gmx grompp -f ../minim.mdp -c "${fname}_solv_ions.gro" -p topol.top -o em.tpr
    $gmx mdrun -v -deffnm em -nb gpu -ntmpi 1

    #NVT（温度安定化）
    $gmx grompp -f ../nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
    $gmx mdrun -deffnm nvt -nb gpu -ntmpi 1

    #NPT（圧力安定化）
    $gmx grompp -f ../npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
    $gmx mdrun -deffnm npt -nb gpu -ntmpi 1

    #MD Production Run
    #md.mdpでMDの時間を設定できる
    $gmx grompp -f ../md.mdp -c npt.gro -t npt.cpt -p topol.top -o "${workdir}.tpr"
    $gmx mdrun -deffnm "$workdir" -nb gpu -ntmpi 1

    # trajectory のPBC補正
    echo "0" | $gmx trjconv -s "${workdir}.tpr" -f "${workdir}.xtc" -o "${workdir}_nojump.xtc" -pbc nojump
    echo -e "1\n0" | $gmx trjconv -s "${workdir}.tpr" -f "${workdir}_nojump.xtc" -o "${workdir}_noPBC.xtc" -center -pbc mol -ur compact

    cd ..
    echo "Done: $workdir"
  done
done

