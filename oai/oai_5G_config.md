@TOC[OAI 5G Config Parameters]


## Configure Parameters

1. 
    | Args           | Value                 | Describe |
    |----------------|-----------------------|----------|
    | Active_gNBs    | "gNB-Eurecom-5GNRBox" |          |
    | Asn1_verbosity | "none"                |          |


2. gNBs
    | Args               | Value                         | Describe       |
    |--------------------|-------------------------------|----------------|
    | gNB_ID             | 0xe00                         | Identification |
    | cell_type          | "CELL_MACRO_GNB"              | Identification |
    | gNB_ID             | "gNB-Eurecom-5GNRBox"         | Identification |
    |--------------------|-------------------------------|----------------|
    | tracking_area_code | 1                             |                |
    | plmn_list          | mcc=208; mnc=93; mnc_length=2 |                |
    | tr_s_preference    | "local_mac"                   |                |
    |--------------------|-------------------------------|----------------|

    | Args                               | Value  | Describe                   |
    |------------------------------------|--------|----------------------------|
    | ssb_SubcarrierOffset               | 0      |                            |
    | pdsch_AntennaPorts                 | 1      |                            |
    |------------------------------------|--------|----------------------------|
    | servingCellConfigCommon            |        |                            |
    | physCellId                         | 0      |                            |
    | absoluteFrequencySSB               | 641032 |                            |
    | dl_frequencyBand                   | 78     |                            |
    | dl_absoluteFrequencyPointA         | 640000 |                            |
    | dl_offstToCarrier                  | 0      |                            |
    | dl_subcarrierSpacing               | 1      | 0=15, 1=30, 2=60, 3=120kHz |
    | dl_carrierBandwidth                | 106    |                            |
    |------------------------------------|--------|----------------------------|
    | initialDLBWPlocationAndBandwidth   | 13475  |                            |
    | initialDLBWPsubcarrierSpacing      | 1      | 0=15, 1=30, 2=60, 3=120kHz |
    | initialDLBWPcontrolResoureSetZero  | 12     |                            |
    | initialDLBWPsearchSpaceZero        | 0      |                            |
    | initialDLBWPk0_0                   | 0      | pdsch-ConfigCommon         |
    | initialDLBWPmappingType_0          | 0      | 0=typeA, 1=typeB           |
    | initialDLBWPstartSymbolAndLength_0 | 40     |                            |
    | initialDLBWPk0_1                   | 0      |                            |
    | initialDLBWPmappingType_1          | 0      |                            |
    | initialDLBWPstartSymbolAndLength_1 | 53     |                            |
    | initialDLBWPk0_2                   | 0      |                            |
    | initialDLBWPmappingType_2          | 0      |                            |
    | initialDLBWPstartSymbolAndLength_2 | 54     |                            |
    |------------------------------------|--------|----------------------------|
    | ul_frequencyBand                   | 78     |                            |
    | ul_offstToCarrier                  | 0      |                            |
    | ul_subcarrierSpacing               | 1      |                            |
    | ul_carrierBandwidth                | 106    |                            |
    | pMax                               | 20     |                            |
    |------------------------------------|--------|----------------------------|
    | initialULBWPlocationAndBandwidth   | 13475  |                            |
    | initialULBWPsubcarrierSpacing      | 1      |                            |
    |------------------------------------|--------|----------------------------|
    | prach_ConfigurationIndex           | 98     |                            |
    | prach_msg1_FDM                     | 0      |                            |


| Name                 | Value                     | Describe |
|----------------------|---------------------------|----------|
| Active_gNBs          | ( "gNB-Eurecom-5GNRBox"); |
| Asn1_verbosity       | "none";                   |
| gNBs                 |                           |
| gNB_ID               | 0xe00;                    |
| cell_type            | "CELL_MACRO_GNB";         |
| gNB_name             | "gNB-Eurecom-5GNRBox";    |
| tracking_area_code   | 1;                        |
| tr_s_preference      | "local_mac"               |
| ssb_SubcarrierOffset | 0;                        |
| pdsch_AntennaPorts   | 1;                        |

| Args                                         | Value                          | Describe |
|----------------------------------------------|--------------------------------|----------|
| servingCellConfigCommon                      | (                              |
| physCellId                                   | 0;                             |
| absoluteFrequencySSB                         | 641032;                        |
| dl_frequencyBand                             | 78;                            |
| dl_absoluteFrequencyPointA                   | 640000;                        |
| dl_offstToCarrier                            | 0;                             |
| dl_subcarrierSpacing                         | 1;                             |
| dl_carrierBandwidth                          | 106;                           |
| initialDLBWPlocationAndBandwidth             | 13475;                         |
| initialDLBWPsubcarrierSpacing                | 1;                             |
| initialDLBWPcontrolResourceSetZero           | 12;                            |
| initialDLBWPsearchSpaceZero                  | 0;                             |
| initialDLBWPk0_0                             | 0;                             |
| initialDLBWPmappingType_0                    | 0;                             |
| initialDLBWPstartSymbolAndLength_0           | 40;                            |
| initialDLBWPk0_1                             | 0;                             |
| initialDLBWPmappingType_1                    | 0;                             |
| initialDLBWPstartSymbolAndLength_1           | 53;                            |
| initialDLBWPk0_2                             | 0;                             |
| initialDLBWPmappingType_2                    | 0;                             |
| initialDLBWPstartSymbolAndLength_2           | 54;                            |
| ul_frequencyBand                             | 78;                            |
| ul_offstToCarrier                            | 0;                             |
| ul_subcarrierSpacing                         | 1;                             |
| ul_carrierBandwidth                          | 106;                           |
| pMax                                         | 20;                            |
| initialULBWPlocationAndBandwidth             | 13475;                         |
| initialULBWPsubcarrierSpacing                | 1;                             |
| prach_ConfigurationIndex                     | 98;                            |
| prach_msg1_FDM                               | 0;                             |
| prach_msg1_FrequencyStart                    | 0;                             |
| zeroCorrelationZoneConfig                    | 13;                            |
| preambleReceivedTargetPower                  | -118;                          |
| #preamblTransMax (0...10)                    | (3,4,5,6,7,8,10,20,50,100,200) |
| preambleTransMax                             | 6;                             |
| powerRampingStep                             | 1;                             |
| ra_ResponseWindow                            | 4;                             |
| ssb_perRACH_OccasionAndCB_PreamblesPerSSB_PR | 3;                             |
| ssb_perRACH_OccasionAndCB_PreamblesPerSSB    | 15;                            |
| ra_ContentionResolutionTimer                 | 7;                             |
| rsrp_ThresholdSSB                            | 19;                            |
| prach_RootSequenceIndex_PR                   | 1;                             |
| prach_RootSequenceIndex                      | 1;                             |
| msg1_SubcarrierSpacing                       | 1,                             |
| restrictedSetConfig                          | 0,                             |
| initialULBWPk2_0                             | 2;                             |
| initialULBWPmappingType_0                    | 1                              |
| initialULBWPstartSymbolAndLength_0           | 55;                            |
| initialULBWPk2_1                             | 2;                             |
| initialULBWPmappingType_1                    | 1;                             |
| initialULBWPstartSymbolAndLength_1           | 69;                            |
| msg3_DeltaPreamble                           | 1;                             |
| p0_NominalWithGrant                          | -90;                           |
| pucchGroupHopping                            | 0;                             |
| hoppingId                                    | 40;                            |
| p0_nominal                                   | -90;                           |
| ssb_PositionsInBurst_PR                      | 2;                             |
| ssb_PositionsInBurst_Bitmap                  | 1;                             |
| ssb_periodicityServingCell                   | 2;                             |
| dmrs_TypeA_Position                          | 0;                             |
| subcarrierSpacing                            | 1;                             |
| referenceSubcarrierSpacing                   | 1;                             |
| dl_UL_TransmissionPeriodicity                | 6;                             |
| nrofDownlinkSlots                            | 7;                             |
| nrofDownlinkSymbols                          | 6;                             |
| nrofUplinkSlots                              | 2;                             |
| nrofUplinkSymbols                            | 4;                             |
| ssPBCH_BlockPower                            | 10;                            |
| SCTP_INSTREAMS                               | 2;                             |
| SCTP_OUTSTREAMS                              | 2;                             |
| ipv6                                         | "192:168:30::17";              |
| active                                       | "yes";                         |
| preference                                   | "ipv4";                        |
| GNB_INTERFACE_NAME_FOR_S1_MME                | "eth0";                        |
| GNB_IPV4_ADDRESS_FOR_S1_MME                  | "192.168.12.111/24";           |
| GNB_INTERFACE_NAME_FOR_S1U                   | "eth0";                        |
| GNB_IPV4_ADDRESS_FOR_S1U                     | "192.168.12.111/24";           |
| GNB_PORT_FOR_S1U                             | 2152; # Spec 2152              |



| Args            | Value        |
|-----------------|--------------|
| MACRLCs         | (            |
| num_cc          | 1;           |
| tr_s_preference | "local_L1";  |
| tr_n_preference | "local_RRC"; |

| Args            | Value        |
|-----------------|--------------|
| L1s             | (            |
| num_cc          | 1;           |
| tr_n_preference | "local_mac"; |

| Args                          | Value       |
|-------------------------------|-------------|
| RUs                           | (           |
| local_rf                      | "yes"       |
| nb_tx                         | 1           |
| nb_rx                         | 1           |
| att_tx                        | 0           |
| att_rx                        | 0;          |
| bands                         | [7];        |
| max_pdschReferenceSignalPower | -27;        |
| max_rxgain                    | 114;        |
| eNB_instances                 | [0];        |
| clock_src                     | "external"; |


| Args                 | Value                       |
|----------------------|-----------------------------|
| THREAD_STRUCT        | (                           |
| parallel_config      | "PARALLEL_RU_L1_TRX_SPLIT"; |
| worker_config        | "WORKER_ENABLE";            |
| global_log_level     | "info";                     |
| global_log_verbosity | "medium";                   |
| hw_log_level         | "info";                     |
| hw_log_verbosity     | "medium";                   |
| phy_log_level        | "info";                     |
| phy_log_verbosity    | "medium";                   |
| mac_log_level        | "info";                     |
| mac_log_verbosity    | "high";                     |
| rlc_log_level        | "info";                     |
| rlc_log_verbosity    | "medium";                   |
| pdcp_log_level       | "info";                     |
| pdcp_log_verbosity   | "medium";                   |
| rrc_log_level        | "info";                     |
| rrc_log_verbosity    | "medium";                   |
