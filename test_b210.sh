#!/usr/bin/env bash


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
read -p "Do you want to perform b210 uhd driver test? <y/n>: " prompt
if [[ $prompt =~ [yY](es)* ]]; then
  test_result_dir="${0%/*}"
  echo "test result directory: $test_result_dir"
  # Find the device
  sudo uhd_usrp_probe
  sudo uhd_find_devices

  # Benchmarks interface with device
  sudo ./benchmark_rate --rx_rate 10e6 --tx_rate 10e6
  
  # Saves samples to file
  sudo ./rx_samples_to_file --freq 98e6 --rate 5e6 \
    --gain 20 --duration 10 "${test_result_dir}/usrp_samples.dat"
  
  # Transmits samples from file
  sudo ./tx_samples_from_file --freq 915e6 --rate 5e6 \
    --gain 10 "${test_result_dir}/usrp_samples.dat"
  
  # Delete the usrp_samples.dat
  sudo rm -rf "${test_result_dir}/usrp_samples.dat"
  
  # Create ASCII/Ncurses FFT
  sudo ./rx_ascii_art_dft --freq 98e6 --rate 5e6 --gain 20 --bw 5e6 --ref-lvl -30
  
  # Transmits specific waveform
  sudo ./tx_waveforms --freq 915e6 --rate 5e6 --gain 0
fi


read -p "Do you want to perform b210 gnuradio test? <y/n>: " prompt
if [[ $prompt =~ [yY](es)* ]]; then
  read -p "Input the gnuradio .py file path: " gr_py_file_path
  gr_py_file_path="$HOME/projects/gnu_radio/FM_recorder_v2.py"
  if [[ -e $gr_py_file_path ]]; then
    echo "gnuradio python file exists"
    /usr/bin/python2 -u $gr_py_file_path
  else
    echo "gnuradio python file doesn't exist"
  fi
fi

