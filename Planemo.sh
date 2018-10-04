





conda create -y --quiet --use-local --override-channels --channel iuc --channel bioconda --channel conda-forge --channel defaults --name __fleeqtk@1.3 fleeqtk=1.3
 # or
conda create --use-local --name __fleeqtk@1.3 fleeqtk=1.3
 
 # check if env is created
ls ~/miniconda3/envs/

planemo test --conda_use_local fleeqtk_seq.xml