#!/bin/bash

# Setting up colors for better readability

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Function to check if nmap is installed, if not, install it

nmaptest() {

  test -f /usr/bin/nmap

  if [ "$(echo $?)" -ne 0 ]; then

    sudo apt-get install nmap -y > /dev/null 2>&1

    if [ "$(echo $?)" -ne 0 ]; then

      sudo dnf install nmap -y > /dev/null 2>&1

    elif [ "$(echo $?)" -ne 0 ]; then

      sudo pacman -S nmap -y > /dev/null 2>&1

    fi

  fi

}

# Function to test if an IP is active by pinging it

iptest() {

  clear
  echo -ne "$greenColour\n[?]$grayColour Enter the IP: " && read ip
  ping -c 1 $ip | grep "ttl" > /dev/null 2>&1

  if [ "$(echo $?)" -ne 0 ]; then

    echo -e "$redColour[!]$grayColour IP is not active"
    iptest

  fi

}

# Checking if the script is run as root

if [ $(id -u) -ne 0 ]; then

    echo -e "\n$redColour[!]$grayColour You must be root to run the script -> (sudo $0)"
    exit 1

else

    nmaptest
    clear
    iptest

    while true; do

      echo -e "\n1) Quick but noisy scan"
      echo "2) Normal scan"
      echo "3) Silent scan (May take longer than normal)"
      echo "4) Service and version scan"
      echo "5) Full scan"
      echo "6) UDP protocol scan"
      echo "7) Exit"

      echo -ne "${greenColour}[?]${grayColour} Select an option: " && read option

      case $option in

       1)

        clear && echo "Scanning..." && nmap -p- --open --min-rate 5000 -T5 -sS -Pn -n -v $ip | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+" > results/nmap-fast-scan-result-$ip.txt && echo -e "${blueColour}Results saved in nmap-fast-scan-result-$ip.txt${endColour}"
        ;;

       2)

        clear && echo "Scanning..." && nmap -p- --open $ip | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+" > results/nmap-normal-scan-result-$ip.txt && echo -e "${blueColour}Results saved in results/nmap-normal-scan-result-$ip.txt${endColour}"
        ;;

       3)

        clear && echo "Scanning..." && nmap -p- -T2 -sS -Pn -f $ip | grep -E "^[0-9]+\/[a-z]+\s+open\s+[a-z]+" > results/nmap-silent-scan-result-$ip.txt && echo -e "${blueColour}Results saved in results/nmap-silent-scan-result-$ip.txt${endColour}"
        ;;

       4)

        clear && echo "Scanning..." && nmap -sV -sC $ip > results/nmap-services-scan-result-$ip.txt && echo -e "${blueColour}Results saved in results/nmap-services-scan-result-$ip.txt${endColour}"
        ;;

       5)

        clear && echo "Scanning..." && nmap -p- -sS -sV -sC --min-rate 5000 -n -Pn $ip > results/nmap-full-scan-result-$ip.txt && echo -e "${blueColour}Results saved in results/nmap-full-scan-result-$ip.txt${endColour}"
        ;;

       6)

        clear && echo "Scanning..." && nmap -sU --top-ports 200 --min-rate=5000 -n -Pn $ip > results/nmap-udp-scan-result-$ip.txt && echo -e "${blueColour}Results saved in results/nmap-udp-scan-result-$ip.txt${endColour}"
        ;;

       7)

        break
        ;;

       *)

            echo -e "\n$redColour[!]$grayColour Option not found"
            ;;

      esac

    done

fi

# Function to handle script termination

finish() {

    echo -e "\n$redColour[!]$grayColour Closing the script..."
    exit

}

trap finish SIGINT