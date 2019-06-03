#!/bin/bash
export PATH=$PATH:"/Applications/GAMS26.1/GAMS Terminal.app/../sysdir" && cd ~

cd ~/Documents/Projects/R2_SIIP/GDX_data/

gdxdump ERCOT_SIIP_20190513.gdx symb=CAP format=csv noHeader >> Var_CAP.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=INV format=csv noHeader >> Var_INV.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=INVREFURB format=csv noHeader >> Var_INVREFURB.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=EXTRA_PRESCRIP format=csv noHeader >> Var_EXTRA_PRESCRIP.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=INV_RSC format=csv noHeader >> Var_INV_RSC.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=GEN format=csv noHeader >> Var_GEN.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=STORAGE_IN format=csv noHeader >> Var_STORAGE_IN.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=STORAGE_OUT format=csv noHeader >> Var_STORAGE_OUT.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=STORAGE_LEVEL format=csv noHeader >> Var_STORAGE_LEVEL.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=CURT format=csv noHeader >> Var_CURT.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=MINGEN format=csv noHeader >> Var_MINGEN.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=FLOW format=csv noHeader >> Var_FLOW.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=OPRES_FLOW format=csv noHeader >> Var_OPRES_FLOW.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=PRMTRADE format=csv noHeader >> Var_PRMTRADE.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=OPRES format=csv noHeader >> Var_OPRES.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=GasUsed format=csv noHeader >> Var_GasUsed.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=Vgasbinq_national format=csv noHeader >> Var_Vgasbinq_national.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=Vgasbinq_regional format=csv noHeader >> Var_Vgasbinq_regional.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=BIOUSED format=csv noHeader >> Var_BIOUSED.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=RECS format=csv noHeader >> Var_RECS.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=ACP_Purchases format=csv noHeader >> Var_ACP_Purchases.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=EMIT format=csv noHeader >> Var_EMIT.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=CAPTRAN format=csv noHeader >> Var_CAPTRAN.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=INVTRAN format=csv noHeader >> Var_INVTRAN.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=INVSUBSTATION format=csv noHeader >> Var_INVSUBSTATION.csv
gdxdump ERCOT_SIIP_20190513.gdx symb=LOAD format=csv noHeader >> Var_LOAD.csv
