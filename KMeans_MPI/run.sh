make clean

sleep 0.1

make

sleep 0.1

if [ "$#" -ne 2 ]
then
    echo "---------------------------------------------------------"
    echo "OPS, worng number of parameters."
    echo "Try:  ./run.sh   <liczba_procesow>   <liczba_klastrow>"
    echo "---------------------------------------------------------"
else
    mpirun -n $1 ./kmeans $2
fi
