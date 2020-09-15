#!/usr/bin/env bash


function test_tx_waveforms() {
#UHD TX Waveforms Allowed options:
#--help                    help message
#--args arg                single uhd device address args
#--spb arg (=0)            samples per buffer, 0 for default
#--nsamps arg (=0)         total number of samples to transmit
#--rate arg                rate of outgoing samples
#--freq arg                RF center frequency in Hz
#--lo-offset arg (=0)      Offset for frontend LO in Hz (optional)
#--ampl arg (=0.300000012) amplitude of the waveform [0 to 0.7]
#--gain arg                gain for the RF chain
#--ant arg                 antenna selection
#--subdev arg              subdevice specification
#--bw arg                  analog frontend filter bandwidth in Hz
#--wave-type arg (=CONST)  waveform type (CONST, SQUARE, RAMP, SINE)
#--wave-freq arg (=0)      waveform frequency in Hz
#--ref arg (=internal)     clock reference (internal, external, mimo, gpsdo)
#--pps arg                 PPS source (internal, external, mimo, gpsdo)
#--otw arg (=sc16)         specify the over-the-wire sample mode
#--channels arg (=0)       which channels to use (specify "0", "1", "0,1", etc)
#--int-n                   tune USRP with integer-N tuning
  echo "Performing tx waveforms test"

  test_freq=(778e6 880e6 935e6 955e6 1810e6 1835e6 1875e6 2120e6 2150e6 2350e6 \
    2500e6 2550e6 2650e6 2655e6)

  test_gain=(10 20 30 40 50 60 70 80 90 100 110 120 130)
  #test_gain=(90)

  for i in ${test_freq[@]}; do
    for j in ${test_gain[@]}; do
      echo "############################################################"
      printf "set test frequency=%s, test gain=%s\n" $i $j
      echo "############################################################"
      sudo ./tx_waveforms --freq $i --rate 5e6 --gain $j \
        --ampl 0.7 --wave-type SINE --wave-freq 0.1e6
      #sleep 10
      #sudo pkill -INT tx_waveforms
    done
  done

  echo ""
  echo "Tx waveforms test end"
  sleep 5
}

read -p "Input the uhd install prefix here <Default /usr/local>: " \
  uhd_install_prefix
if [[ -z ${uhd_install_prefix} ]]; then
  uhd_install_prefix="/usr/local"
fi

echo "uhd install prefix: ${uhd_install_prefix}"
uhd_example_dir="${uhd_install_prefix}/lib/uhd/examples"
echo "uhd example directory: ${uhd_example_dir}"

if [[ -d ${uhd_example_dir} ]]; then
  cd ${uhd_example_dir} && echo "Enter the uhd example directory $PWD"
else
  echo "${uhd_example_dir} is not a valid directory"
fi

# performing test
echo "############################################################"
read -p "Do you want to perform b210 uhd driver test? <y/n>: " prompt
echo "############################################################"
if [[ $prompt =~ [yY](es)* ]]; then
  test_result_dir="${0%/*}"
  echo "test result directory: $test_result_dir"
  # Find the device
  #sudo uhd_usrp_probe
  sudo uhd_find_devices && printf "uhd device found\n\n"

  ## Benchmarks interface with device
  #sudo ./benchmark_rate --rx_rate 10e6 --tx_rate 10e6
  #
  ## Saves samples to file
  #sudo ./rx_samples_to_file --freq 98e6 --rate 5e6 \
  #  --gain 20 --duration 10 "${test_result_dir}/usrp_samples.dat"
  #
  ## Transmits samples from file
  #sudo ./tx_samples_from_file --freq 915e6 --rate 5e6 \
  #  --gain 10 "${test_result_dir}/usrp_samples.dat"
  #
  ## Delete the usrp_samples.dat
  #sudo rm -rf "${test_result_dir}/usrp_samples.dat"
  #
  ## Create ASCII/Ncurses FFT
  #sudo ./rx_ascii_art_dft --freq 98e6 --rate 5e6 --gain 20 --bw 5e6 --ref-lvl -30
  
  # Transmits specific waveform
  if [[ $? ]]; then
    test_tx_waveforms
  else
    echo "Stop tx waveforms test, please check your uhd devices' connection"
    echo ""
  fi
fi


#echo "############################################################"
#read -p "Do you want to perform b210 gnuradio test? <y/n>: " prompt
#echo "############################################################"
#if [[ $prompt =~ [yY](es)* ]]; then
#  read -p "Input the gnuradio .py file path: " gr_py_file_path
#  if [[ ! -e $gr_py_file_path ]]; then
#    gr_py_file_path="$HOME/projects/gnu_radio/FM_recorder_v2.py"
#  fi
#  if [[ -e $gr_py_file_path ]]; then
#    echo "gnuradio python file exists"
#    /usr/bin/python2 -u $gr_py_file_path
#  else
#    echo "gnuradio python file doesn't exist"
#  fi
#fi
