start_time=`date +%s`
print_green(){
    echo -e "\e[32m$1\e[39m"
}


echo -e "\n\n"
echo "----------------------------------------------------------------------------"
print_green "Installation completes"
echo -e "Please run source /home/developer/Development/ros/devel/setup.sh"
echo " before runing any ros packages"
echo "----------------------------------------------------------------------------"
echo Execution time is $(expr `date +%s` - $start_time) s
